using System;
using System.Reflection;
using Cinemachine;
using UnityEngine;
using UnityEngine.InputSystem;
using InputPointer = UnityEngine.InputSystem.Pointer;

public class PlayerController : MonoBehaviour
{
    [Header("Input Actions (.inputactions をアサイン)")]
    public InputActionReference forwardAction; // Holdで前進
    public InputActionReference dragAction;    // Vector2: マウス/タッチのDelta

    [Header("Movement")]
    public float normalSpeed = 6f;
    public float yawFactor = 90f;
    public float pitchFactor = 90f;
    [SerializeField] private float forwardAcceleration = 30f;

    [Header("Drag Stick")]
    [Tooltip("タッチ操作時のスティック半径（ピクセル単位）")]
    [SerializeField] private float dragStickRadiusPixels = 200f;

    [Header("Orientation")]
    [SerializeField] private PlayerVisualStabilizer visualStabilizer;
    [SerializeField] private float maxPitchDegrees = 20f;
    [SerializeField] private float pitchAutoLevelSpeed = 4f;
    [SerializeField] private float visualInputDamping = 8f;

    [Header("Forward Inertia")]
    [Tooltip("前進を止めた後に慣性として維持する時間（秒）")]
    public float inertiaDuration = 0.35f;
    [Tooltip("慣性の減速カーブ（X=経過割合 0-1, Y=速度倍率）")]
    public AnimationCurve inertiaSpeedCurve = AnimationCurve.EaseInOut(0f, 1f, 1f, 0f);

    [Header("Gentle Fall (前進停止後の自然落下)")]
    public float fallDelaySeconds = 0.5f;   // 何秒後に落下開始
    public float fallAccel = 2.0f;   // 落下加速度(擬似)
    public float maxFallSpeed = 3.0f;   // 最大落下速度(絶対値)

    [Header("Refs")]
    public BoostController boost;   // ← BoostController をドラッグで割り当て
    public Animator animator;       // 任意
    [SerializeField] private CinemachineVirtualCamera virtualCamera;
    [SerializeField] private VCamOrientationSwitcher orientationSwitcher;
    [SerializeField] private float boostFovIncrease = 5f;
    [SerializeField] private float boostFovAdjustSpeed = 10f;

    // runtime state
    private bool forwardHeld;
    private Vector2 drag;
    private float yawAngle;
    private float currentPitch;
    private Vector2 smoothedVisualInput;
    private float timeSinceForwardReleased = 0f;
    private float verticalVel = 0f; // 自然落下用（Rigidbody非使用の簡易実装）
    private float inertiaTimer = 0f;
    private Vector3 inertiaDirection = Vector3.forward;
    private float inertiaSpeed = 0f;
    private float inspectorCameraFov;
    private bool inspectorCameraFovCaptured;
    private float currentForwardSpeed = 0f;
    private bool dragStickActive;
    private Vector2 dragStickCenter;
    private int dragTouchId = -1;

    void OnEnable()
    {
        Enable(forwardAction, OnForward);
        Enable(dragAction, OnDrag);
        Debug.Log("[PlayerController] Input ENABLED");
    }
    void OnDisable()
    {
        Disable(forwardAction, OnForward);
        Disable(dragAction, OnDrag);
        Debug.Log("[PlayerController] Input DISABLED");
    }

    void Update()
    {
        // 速度決定：BoostController の倍率を採用
        float speedMul = (boost != null) ? boost.CurrentSpeedMultiplier : 1f;
        float targetSpeed = normalSpeed * speedMul;
        bool isBoosting = boost && boost.IsBoosting;

        if (!virtualCamera && boostFovIncrease != 0f)
        {
            // 保険で開始時に取得できなかった場合に探して記録
            virtualCamera = GetComponentInChildren<CinemachineVirtualCamera>();
            if (virtualCamera)
            {
                ConfigureCameraWorldUp();
                EnsureOrientationSwitcher();
                if (!inspectorCameraFovCaptured)
                {
                    inspectorCameraFov = virtualCamera.m_Lens.FieldOfView;
                    inspectorCameraFovCaptured = true;
                }
            }
        }
        if (virtualCamera)
        {
            EnsureOrientationSwitcher();

            if (!inspectorCameraFovCaptured)
            {
                inspectorCameraFov = virtualCamera.m_Lens.FieldOfView;
                inspectorCameraFovCaptured = true;
            }

            float baseFov = GetBaseFov();

            float targetFov = isBoosting
                ? baseFov + Mathf.Max(0f, boostFovIncrease)
                : baseFov;

            float current = virtualCamera.m_Lens.FieldOfView;
            float next = (boostFovAdjustSpeed > 0f)
                ? Mathf.MoveTowards(current, targetFov, boostFovAdjustSpeed * Time.deltaTime)
                : targetFov;
            virtualCamera.m_Lens.FieldOfView = next;
        }

        // アニメーター
        if (animator)
        {
            bool isFlying = forwardHeld || inertiaTimer > 0f;
            animator.SetBool("IsFlying", isFlying);
            if (boost) animator.SetBool("IsBoosting", isBoosting);
        }

        UpdateOrientation(Time.deltaTime);
        Vector3 forwardDirection = GetCurrentForward();

        // 前進
        if (forwardHeld)
        {
            float accelStep = Mathf.Max(forwardAcceleration, 0f) * Time.deltaTime;
            currentForwardSpeed = Mathf.MoveTowards(currentForwardSpeed, targetSpeed, accelStep);
            transform.position += forwardDirection * currentForwardSpeed * Time.deltaTime;

            // 前進中は落下リセット
            timeSinceForwardReleased = 0f;
            verticalVel = 0f;
            inertiaTimer = 0f;
        }
        else
        {
            float accelStep = Mathf.Max(forwardAcceleration, 0f) * Time.deltaTime;
            currentForwardSpeed = Mathf.MoveTowards(currentForwardSpeed, 0f, accelStep);

            if (inertiaTimer > 0f)
            {
                float normalizedTime = 1f - (inertiaTimer / Mathf.Max(inertiaDuration, Mathf.Epsilon));
                float curve = inertiaSpeedCurve != null
                    ? inertiaSpeedCurve.Evaluate(Mathf.Clamp01(normalizedTime))
                    : 1f;
                transform.position += inertiaDirection * (inertiaSpeed * curve) * Time.deltaTime;
                inertiaTimer = Mathf.Max(0f, inertiaTimer - Time.deltaTime);

                timeSinceForwardReleased = 0f;
                verticalVel = 0f;
            }
            else
            {
                // 停止してからの経過
                timeSinceForwardReleased += Time.deltaTime;

                // 遅延後にゆっくり自然落下（Rigidbodyなし版）
                if (timeSinceForwardReleased >= fallDelaySeconds)
                {
                    // v = v + a*dt（下向きを負方向とする）
                    verticalVel = Mathf.MoveTowards(
                        verticalVel,
                        -maxFallSpeed,
                        fallAccel * Time.deltaTime
                    );
                    transform.position += Vector3.up * verticalVel * Time.deltaTime;
                }
            }
        }

        // デバッグ（必要なら）
        // Debug.Log($"FWD:{forwardHeld} BOOST:{(boost?boost.IsBoosting:false)} MUL:{speedMul:F2} Vv:{verticalVel:F2}");
    }

    // ---- callbacks ----
    private void OnForward(InputAction.CallbackContext ctx)
    {
        bool pressed = ctx.ReadValueAsButton();

        if (!pressed && forwardHeld)
        {
            BeginInertia();
            currentForwardSpeed = 0f;
            ResetDragStick();
        }
        else if (pressed)
        {
            inertiaTimer = 0f;
            CaptureDragStickCenter(ctx);
        }

        forwardHeld = pressed;
    }
    private void OnDrag(InputAction.CallbackContext ctx)
    {
        if (ctx.canceled)
        {
            ResetDragStick();
            return;
        }

        if (!EnsureDragStickActive(ctx))
        {
            if (ctx.performed || ctx.started)
                drag = ctx.ReadValue<Vector2>();
            return;
        }

        if (!TryGetDragPointerPosition(out Vector2 pointerPosition))
        {
            ResetDragStick();
            return;
        }

        Vector2 rawDelta = pointerPosition - dragStickCenter;
        drag = ConvertPointerToStick(rawDelta);
    }

    // ---- util ----
    private static void Enable(InputActionReference r, System.Action<InputAction.CallbackContext> cb)
    {
        if (!r) { Debug.LogWarning("InputActionReference not set"); return; }
        r.action.Enable();
        r.action.started += cb;
        r.action.performed += cb;
        r.action.canceled += cb;
    }
    private static void Disable(InputActionReference r, System.Action<InputAction.CallbackContext> cb)
    {
        if (!r) return;
        r.action.started -= cb;
        r.action.performed -= cb;
        r.action.canceled -= cb;
        r.action.Disable();
    }

    private void BeginInertia()
    {
        if (inertiaDuration <= 0f)
        {
            inertiaTimer = 0f;
            return;
        }

        if (currentForwardSpeed <= 0f)
        {
            inertiaTimer = 0f;
            return;
        }

        inertiaTimer = inertiaDuration;
        inertiaDirection = GetCurrentForward();
        inertiaSpeed = currentForwardSpeed;
    }

    void Awake()
    {
        yawAngle = transform.eulerAngles.y;
        if (!visualStabilizer)
        {
            visualStabilizer = GetComponent<PlayerVisualStabilizer>();
            if (!visualStabilizer)
                visualStabilizer = GetComponentInChildren<PlayerVisualStabilizer>();
        }

        if (visualStabilizer && visualStabilizer.root == null)
        {
            visualStabilizer.root = transform;
        }

        if (!virtualCamera)
        {
            virtualCamera = GetComponentInChildren<CinemachineVirtualCamera>();
        }

        if (virtualCamera)
        {
            inspectorCameraFov = virtualCamera.m_Lens.FieldOfView;
            inspectorCameraFovCaptured = true;
            EnsureOrientationSwitcher();
            ConfigureCameraWorldUp();
        }
    }

    private float GetBaseFov()
    {
        if (orientationSwitcher)
        {
            return orientationSwitcher.GetDefaultFieldOfView();
        }

        if (!inspectorCameraFovCaptured)
        {
            inspectorCameraFov = virtualCamera.m_Lens.FieldOfView;
            inspectorCameraFovCaptured = true;
        }

        return inspectorCameraFov;
    }

    private void EnsureOrientationSwitcher()
    {
        if (orientationSwitcher)
            return;

        orientationSwitcher = GetComponentInChildren<VCamOrientationSwitcher>();
        if (!orientationSwitcher && virtualCamera)
            orientationSwitcher = virtualCamera.GetComponent<VCamOrientationSwitcher>();
    }

    private void UpdateOrientation(float deltaTime)
    {
        // yaw
        if (Mathf.Abs(drag.x) > 0.0001f)
        {
            float yawDelta = drag.x * yawFactor * deltaTime;
            yawAngle += yawDelta;
            yawAngle = Mathf.Repeat(yawAngle, 360f);
        }

        // pitch
        float pitchLimit = visualStabilizer ? visualStabilizer.maxPitchDegrees : maxPitchDegrees;
        if (Mathf.Abs(drag.y) > 0.0001f)
        {
            float pitchDelta = -drag.y * pitchFactor * deltaTime;
            currentPitch = Mathf.Clamp(currentPitch + pitchDelta, -pitchLimit, pitchLimit);
        }
        else if (!Mathf.Approximately(currentPitch, 0f))
        {
            currentPitch = Mathf.MoveTowards(currentPitch, 0f, pitchAutoLevelSpeed * deltaTime);
        }

        transform.rotation = Quaternion.Euler(0f, yawAngle, 0f);

        UpdateVisualInputs(deltaTime);
    }

    private void UpdateVisualInputs(float deltaTime)
    {
        if (!visualStabilizer) return;

        Vector2 desired = new Vector2(
            Mathf.Clamp(drag.x, -1f, 1f),
            Mathf.Clamp(-drag.y, -1f, 1f)
        );

        float step = Mathf.Max(visualInputDamping, 0.01f) * deltaTime;
        smoothedVisualInput = Vector2.MoveTowards(smoothedVisualInput, desired, step);

        visualStabilizer.yawInput = smoothedVisualInput.x;
        visualStabilizer.pitchInput = smoothedVisualInput.y;
    }

    private Vector3 GetCurrentForward()
    {
        Quaternion yawRotation = Quaternion.Euler(0f, yawAngle, 0f);
        Quaternion pitchRotation = Quaternion.AngleAxis(currentPitch, Vector3.right);
        Quaternion combined = yawRotation * pitchRotation;
        return combined * Vector3.forward;
    }

    private void ConfigureCameraWorldUp()
    {
        if (!virtualCamera) return;

        if (visualStabilizer)
        {
            if (virtualCamera.Follow == null || virtualCamera.Follow == visualStabilizer.visual)
                virtualCamera.Follow = transform;
            if (virtualCamera.LookAt == null || virtualCamera.LookAt == visualStabilizer.visual)
                virtualCamera.LookAt = transform;
        }
        else
        {
            if (virtualCamera.Follow != transform)
                virtualCamera.Follow = transform;
            if (virtualCamera.LookAt != transform)
                virtualCamera.LookAt = transform;
        }

        var transposer = virtualCamera.GetCinemachineComponent<CinemachineTransposer>();
        ApplyWorldUpBinding(transposer);

        var thirdPerson = virtualCamera.GetCinemachineComponent<Cinemachine3rdPersonFollow>();
        ApplyWorldUpBinding(thirdPerson);

        virtualCamera.m_Lens.Dutch = 0f;
    }

    private void CaptureDragStickCenter(InputAction.CallbackContext ctx)
    {
        dragStickActive = false;
        dragTouchId = -1;

        if (TryGetPointerFromContext(ctx, out Vector2 position, out int touchId))
        {
            dragStickCenter = position;
            dragStickActive = true;
            dragTouchId = touchId;
            drag = Vector2.zero;
            return;
        }

        if (TryGetPointerFromDevices(out position, out touchId))
        {
            dragStickCenter = position;
            dragStickActive = true;
            dragTouchId = touchId;
            drag = Vector2.zero;
        }
    }

    private bool TryGetDragPointerPosition(out Vector2 position)
    {
        if (!dragStickActive)
        {
            position = default;
            return false;
        }

        if (dragTouchId >= 0 && Touchscreen.current != null)
        {
            foreach (var touch in Touchscreen.current.touches)
            {
                if (touch.touchId.ReadValue() == dragTouchId)
                {
                    if (touch.press.isPressed)
                    {
                        position = touch.position.ReadValue();
                        return true;
                    }

                    position = default;
                    return false;
                }
            }
        }
        else
        {
            InputPointer pointer = InputPointer.current;
            if (pointer != null && pointer.press != null && pointer.press.isPressed)
            {
                position = pointer.position.ReadValue();
                return true;
            }

            if (Mouse.current != null && Mouse.current.leftButton.isPressed)
            {
                position = Mouse.current.position.ReadValue();
                return true;
            }
        }

        position = default;
        return false;
    }

    private Vector2 ConvertPointerToStick(Vector2 pointerDelta)
    {
        float radius = Mathf.Max(dragStickRadiusPixels, 1f);
        Vector2 normalized = pointerDelta / radius;
        if (normalized.sqrMagnitude > 1f)
            normalized = normalized.normalized;
        return normalized;
    }

    private void ResetDragStick()
    {
        dragStickActive = false;
        dragTouchId = -1;
        drag = Vector2.zero;
    }

    private bool EnsureDragStickActive(InputAction.CallbackContext ctx)
    {
        if (dragStickActive)
            return true;

        if (ctx.control == null && !(ctx.performed || ctx.started))
            return false;

        if (TryGetPointerFromContext(ctx, out Vector2 position, out int touchId))
        {
            dragStickCenter = position;
            dragStickActive = true;
            dragTouchId = touchId;
            drag = Vector2.zero;
            return true;
        }

        if (TryGetPointerFromDevices(out position, out touchId))
        {
            dragStickCenter = position;
            dragStickActive = true;
            dragTouchId = touchId;
            drag = Vector2.zero;
            return true;
        }

        return false;
    }

    private bool TryGetPointerFromContext(InputAction.CallbackContext ctx, out Vector2 position, out int touchId)
    {
        touchId = -1;

        if (ctx.control == null)
        {
            position = default;
            return false;
        }

        InputDevice device = ctx.control.device;
        if (device is Touchscreen touchscreen)
        {
            foreach (var touch in touchscreen.touches)
            {
                if (!touch.press.isPressed)
                    continue;

                position = touch.position.ReadValue();
                touchId = touch.touchId.ReadValue();
                return true;
            }
        }
        else if (device is InputPointer pointer)
        {
            var pressControl = pointer.press;
            if (pressControl != null && pressControl.isPressed)
            {
                position = pointer.position.ReadValue();
                return true;
            }
        }

        position = default;
        return false;
    }

    private bool TryGetPointerFromDevices(out Vector2 position, out int touchId)
    {
        touchId = -1;

        if (Touchscreen.current != null)
        {
            foreach (var touch in Touchscreen.current.touches)
            {
                if (!touch.press.isPressed)
                    continue;

                position = touch.position.ReadValue();
                touchId = touch.touchId.ReadValue();
                return true;
            }
        }

        InputPointer pointer = InputPointer.current;
        if (pointer != null && pointer.press != null && pointer.press.isPressed)
        {
            position = pointer.position.ReadValue();
            return true;
        }

        if (Mouse.current != null && Mouse.current.leftButton.isPressed)
        {
            position = Mouse.current.position.ReadValue();
            return true;
        }

        position = default;
        return false;
    }

    private static readonly string[] bindingModeMemberNames = { "m_BindingMode", "BindingMode" };
    private static readonly string[] preferredBindingModes =
    {
        "WorldSpace",
        "LockToTargetWithWorldUp",
        "LockToTargetNoRoll"
    };

    private void ApplyWorldUpBinding(object component)
    {
        if (component == null)
            return;

        Type type = component.GetType();
        foreach (string memberName in bindingModeMemberNames)
        {
            FieldInfo field = type.GetField(memberName, BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            if (TryAssignBindingMode(field, component))
                return;

            PropertyInfo property = type.GetProperty(memberName, BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            if (TryAssignBindingMode(property, component))
                return;
        }
    }

    private bool TryAssignBindingMode(FieldInfo field, object instance)
    {
        if (field == null || !field.FieldType.IsEnum)
            return false;

        return TryAssignEnumValue(field.FieldType, value => field.SetValue(instance, value));
    }

    private bool TryAssignBindingMode(PropertyInfo property, object instance)
    {
        if (property == null || !property.CanWrite || !property.PropertyType.IsEnum)
            return false;

        return TryAssignEnumValue(property.PropertyType, value => property.SetValue(instance, value));
    }

    private bool TryAssignEnumValue(Type enumType, Action<object> assign)
    {
        string[] enumNames = Enum.GetNames(enumType);
        foreach (string option in preferredBindingModes)
        {
            foreach (string name in enumNames)
            {
                if (string.Equals(name, option, StringComparison.OrdinalIgnoreCase))
                {
                    object parsed = Enum.Parse(enumType, name);
                    assign(parsed);
                    return true;
                }
            }
        }

        return false;
    }
}
