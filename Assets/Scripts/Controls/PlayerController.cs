using System;
using System.Reflection;
using Cinemachine;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [Header("Input Actions (.inputactions をアサイン)")]
    public InputActionReference forwardAction; // Holdで前進
    public InputActionReference dragAction;    // Vector2: マウス/タッチのDelta

    [Header("Movement")]
    public float normalSpeed = 6f;
    public float yawFactor = 90f;
    public float pitchFactor = 90f;

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
    private float defaultCameraFov;
    private bool cameraFovCached;
    private bool wasBoosting;
    private float baseFovAtBoost;

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
        float speed = normalSpeed * speedMul;
        bool isBoosting = boost && boost.IsBoosting;

        if (!virtualCamera && boostFovIncrease != 0f)
        {
            // 保険で開始時に取得できなかった場合に探して記録
            virtualCamera = GetComponentInChildren<CinemachineVirtualCamera>();
            if (virtualCamera)
                ConfigureCameraWorldUp();
        }
        if (virtualCamera)
        {

            // ブースト開始時に、その瞬間のFOVを基準として記録
            if (isBoosting && !wasBoosting)
                baseFovAtBoost = virtualCamera.m_Lens.FieldOfView;

            // 目標FOVは「基準＋増分」。ブーストしていない時は触らない
            if (isBoosting)
            {
                float target = baseFovAtBoost + Mathf.Max(0f, boostFovIncrease);
                float current = virtualCamera.m_Lens.FieldOfView;
                float next = (boostFovAdjustSpeed > 0f)
                    ? Mathf.MoveTowards(current, target, boostFovAdjustSpeed * Time.deltaTime)
                    : target;
                virtualCamera.m_Lens.FieldOfView = next;
            }
            else if (wasBoosting)
            {
                // ブーストが終わった直後だけ、基準にスムーズに戻す
                float current = virtualCamera.m_Lens.FieldOfView;
                float next = (boostFovAdjustSpeed > 0f)
                    ? Mathf.MoveTowards(current, baseFovAtBoost, boostFovAdjustSpeed * Time.deltaTime)
                    : baseFovAtBoost;
                virtualCamera.m_Lens.FieldOfView = next;
            }

            wasBoosting = isBoosting;
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
            transform.position += forwardDirection * speed * Time.deltaTime;

            // 前進中は落下リセット
            timeSinceForwardReleased = 0f;
            verticalVel = 0f;
            inertiaTimer = 0f;
        }
        else
        {
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
        }
        else if (pressed)
        {
            inertiaTimer = 0f;
        }

        forwardHeld = pressed;
    }
    private void OnDrag(InputAction.CallbackContext ctx)
    {
        if (ctx.performed || ctx.canceled)
            drag = ctx.ReadValue<Vector2>();
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

        inertiaTimer = inertiaDuration;
        inertiaDirection = GetCurrentForward();
        float speedMul = (boost != null) ? boost.CurrentSpeedMultiplier : 1f;
        inertiaSpeed = normalSpeed * speedMul;
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
            defaultCameraFov = virtualCamera.m_Lens.FieldOfView;
            cameraFovCached = true;
            ConfigureCameraWorldUp();
        }
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
