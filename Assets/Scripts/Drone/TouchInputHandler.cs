using UnityEngine;
using UnityEngine.InputSystem;

namespace WonderAir.Drone
{
    [DisallowMultipleComponent]
    public class TouchInputHandler : BaseInputHandler, IInputHandler
    {
        [Header("Input Actions")]
        [SerializeField] private InputActionAsset inputActions;
        [SerializeField] private string pointerContactActionName = "Player/PointerContact";
        [SerializeField] private string pointerDeltaActionName = "Player/PointerDelta";

        [Header("Forward Motion")]
        [SerializeField] private float forwardResponse = 6f;
        [SerializeField] private float releaseDeceleration = 3f;
        [SerializeField] private float releaseHoldDuration = 0.2f;

        [Header("Turning")]
        [SerializeField] private float turnSensitivity = 0.01f;
        [SerializeField] private float turnResponse = 8f;
        [SerializeField] private float rollResponse = 6f;
        [SerializeField] private float inputDeadzone = 0.08f;

        [Header("Vertical Movement")]
        [SerializeField] private float verticalSensitivity = 0.01f;
        [SerializeField] private float liftResponse = 6f;
        [SerializeField] private float liftReleaseSpeed = 5f;
        [SerializeField] private float stationarySpeedThreshold = 0.6f;
        [SerializeField] private float ascendThreshold = 0.25f;

        [Header("Braking")]
        [SerializeField] private float brakeThreshold = 0.35f;
        [SerializeField] private float quickStopDuration = 0.35f;
        [SerializeField] private float quickStopPitch = -0.75f;
        [SerializeField] private float quickStopRecovery = 8f;

        private InputAction pointerContactAction;
        private InputAction pointerDeltaAction;

        private bool pointerHeld;
        private float releaseTimer;
        private float quickStopTimer;
        private Vector2 smoothedDelta;

        private DroneController controller;
        private Rigidbody cachedBody;

        public bool HasActiveInput =>
            pointerHeld || releaseTimer > 0f || quickStopTimer > 0f ||
            Mathf.Abs(Pitch) > 0.05f || Mathf.Abs(Roll) > 0.05f ||
            Mathf.Abs(Yaw) > 0.05f || Mathf.Abs(Lift) > 0.05f;

        private void Awake()
        {
            controller = GetComponent<DroneController>();
            cachedBody = controller != null ? controller.Rb : GetComponent<Rigidbody>();
        }

        private void OnEnable()
        {
            ResolveActions();
            EnableActions(true);
        }

        private void OnDisable()
        {
            EnableActions(false);
        }

        public void HandleInputs()
        {
            if (pointerContactAction == null || pointerDeltaAction == null)
            {
                ResetInputs();
                EvaluateAnyKeyDown();
                return;
            }

            bool contact = pointerContactAction.ReadValue<float>() > 0.5f;
            Vector2 delta = pointerDeltaAction.ReadValue<Vector2>();

            float deltaTime = Time.deltaTime;

            if (contact)
            {
                if (!pointerHeld)
                {
                    pointerHeld = true;
                    releaseTimer = releaseHoldDuration;
                }

                UpdateFromPointer(delta, deltaTime);
            }
            else
            {
                pointerHeld = false;
                ReleaseControl(deltaTime);
            }

            ClampInputs();
            EvaluateAnyKeyDown();
        }

        private void UpdateFromPointer(Vector2 delta, float deltaTime)
        {
            smoothedDelta = Vector2.Lerp(smoothedDelta, delta, deltaTime * turnResponse);

            float turnInput = Mathf.Clamp(smoothedDelta.x * turnSensitivity, -1f, 1f);
            float verticalInput = Mathf.Clamp(smoothedDelta.y * verticalSensitivity, -1f, 1f);

            if (Mathf.Abs(turnInput) < inputDeadzone)
            {
                turnInput = 0f;
            }

            if (Mathf.Abs(verticalInput) < inputDeadzone)
            {
                verticalInput = 0f;
            }

            Yaw = Mathf.Lerp(Yaw, turnInput, turnResponse * deltaTime);
            Roll = Mathf.Lerp(Roll, -turnInput, rollResponse * deltaTime);

            bool movingForward = cachedBody != null && Vector3.Dot(cachedBody.velocity, transform.forward) > 0.5f;
            bool isMoving = cachedBody != null && cachedBody.velocity.magnitude > stationarySpeedThreshold;

            if (verticalInput < -brakeThreshold && movingForward)
            {
                quickStopTimer = quickStopDuration;
            }

            if (quickStopTimer > 0f)
            {
                quickStopTimer -= deltaTime;
                Pitch = Mathf.Lerp(Pitch, quickStopPitch, quickStopRecovery * deltaTime);
            }
            else
            {
                Pitch = Mathf.Lerp(Pitch, 1f, forwardResponse * deltaTime);
            }

            bool stationary = !isMoving || Mathf.Abs(Pitch) < 0.1f;

            if (verticalInput > ascendThreshold)
            {
                if (stationary)
                {
                    Pitch = Mathf.Lerp(Pitch, 0f, forwardResponse * deltaTime);
                }

                Lift = Mathf.Lerp(Lift, Mathf.Clamp(verticalInput, 0f, 1f), liftResponse * deltaTime);
            }
            else if (verticalInput < -ascendThreshold)
            {
                if (stationary)
                {
                    Pitch = Mathf.Lerp(Pitch, 0f, forwardResponse * deltaTime);
                }

                Lift = Mathf.Lerp(Lift, Mathf.Clamp(verticalInput, -1f, 0f), liftResponse * deltaTime);
            }
            else
            {
                Lift = Mathf.Lerp(Lift, 0f, liftReleaseSpeed * deltaTime);
            }

            releaseTimer = releaseHoldDuration;
        }

        private void ReleaseControl(float deltaTime)
        {
            if (releaseTimer > 0f)
            {
                releaseTimer -= deltaTime;
            }
            else
            {
                Pitch = Mathf.MoveTowards(Pitch, 0f, releaseDeceleration * deltaTime);
            }

            quickStopTimer = Mathf.MoveTowards(quickStopTimer, 0f, deltaTime);

            Yaw = Mathf.Lerp(Yaw, 0f, turnResponse * deltaTime);
            Roll = Mathf.Lerp(Roll, 0f, rollResponse * deltaTime);
            Lift = Mathf.Lerp(Lift, 0f, liftReleaseSpeed * deltaTime);
        }

        private void ResetInputs()
        {
            pointerHeld = false;
            releaseTimer = 0f;
            quickStopTimer = 0f;
            smoothedDelta = Vector2.zero;

            Pitch = 0f;
            Roll = 0f;
            Yaw = 0f;
            Lift = 0f;
        }

        private void ClampInputs()
        {
            Pitch = Mathf.Clamp(Pitch, -1f, 1f);
            Roll = Mathf.Clamp(Roll, -1f, 1f);
            Yaw = Mathf.Clamp(Yaw, -1f, 1f);
            Lift = Mathf.Clamp(Lift, -1f, 1f);
        }

        private void ResolveActions()
        {
            if (inputActions == null)
            {
                return;
            }

            pointerContactAction = SafeFindAction(pointerContactActionName);
            pointerDeltaAction = SafeFindAction(pointerDeltaActionName);
        }

        private InputAction SafeFindAction(string actionName)
        {
            if (string.IsNullOrEmpty(actionName))
            {
                return null;
            }

            try
            {
                return inputActions.FindAction(actionName, true);
            }
            catch (System.Exception)
            {
                Debug.LogWarning($"Input action '{actionName}' could not be found on asset '{inputActions?.name}'.");
                return null;
            }
        }

        private void EnableActions(bool enable)
        {
            if (pointerContactAction != null)
            {
                if (enable) pointerContactAction.Enable(); else pointerContactAction.Disable();
            }

            if (pointerDeltaAction != null)
            {
                if (enable) pointerDeltaAction.Enable(); else pointerDeltaAction.Disable();
            }
        }
    }
}
