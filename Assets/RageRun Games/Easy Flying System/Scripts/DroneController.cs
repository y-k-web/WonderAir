using UnityEngine;

namespace RageRunGames.EasyFlyingSystem
{
    // Tuning Notes: turnResponsiveness=6, bankAngleMax=35, bankReturnSpeed=3,
    // acceleration=14, deceleration=10, maxPlanarSpeed=18,
    // baseDrag=1.0, maxDrag=1.5, adjDragMaxSpeed=20
    [DisallowMultipleComponent]
    [RequireComponent(typeof(Rigidbody))]
    [RequireComponent(typeof(BoxCollider))]
    public class DroneController : BaseFlyController
    {
        [Header("Input Settings")] 
        [HideInInspector] public InputType inputType;

        [Header("Controller Settings")]
        [SerializeField] private bool maintainAltitude = true;
        [SerializeField] protected bool useGravityOnNoInput;

        [Header("Flight Control Settings")]
        [SerializeField] private Transform headingReference;
        [SerializeField] private float turnResponsiveness = 6f;
        [SerializeField] private float bankAngleMax = 35f;
        [SerializeField] private float bankReturnSpeed = 3f;
        [SerializeField] private float acceleration = 14f;
        [SerializeField] private float deceleration = 10f;
        [SerializeField] private float maxPlanarSpeed = 18f;
        [SerializeField] private float verticalLiftScale = 1f;

        [Header("Hover Settings")] 
        [SerializeField] protected bool enableHover;

        [Range(0, 10)] [SerializeField] protected float hoverAmplitude = 1.25f;
        [Range(0, 10)] [SerializeField] protected float hoverFrequency = 2f;

        [Header("Quick Stop Settings")]
        [SerializeField] private float quickStopInputThreshold = 0.1f;

        [Header("Ground Settings")] 
        [SerializeField] protected float groundCheckDistance = 0.2f;

        [SerializeField] protected bool decelerateOnGround;
        [SerializeField] protected float decelSpeedOnGround = 4f;

        // 慣性制御用の新しいパラメータ
        [Header("Inertia Settings")]
        [SerializeField] private float baseDrag = 1f; // 抗力の最小値
        [SerializeField] private float maxDrag = 1.5f;    // 抗力の最大値
        [SerializeField] private float adjDragMaxSpeed = 20f; // 最大速度（抗力調整の基準


        private float timer;

        private BaseInputHandler currentInputHandler;
        private BoostController boostController;
        private Vector3 desiredPlanarDirection;
        private Vector3 currentPlanarVelocity;
        private Vector2 lastPlanarInput;

        public bool IsGrounded { get; private set; } = true;

        protected override void Initialize()
        {
            base.Initialize();

            if (InputHandler == null)
            {
                Debug.LogWarning(" No input is added or selected, adding keyboard input as default ");
                InputHandler = gameObject.AddComponent<KeyboardInputHandler>();
            }
            // 抗力の初期値を設定
            rb.drag = baseDrag;
            boostController = GetComponent<BoostController>();
        }

        protected override void Update()
        {
            base.Update();
            IsGrounded = Physics.Raycast(transform.position, Vector3.down, groundCheckDistance);

            if (IsGrounded && rb.velocity != Vector3.zero && decelerateOnGround)
            {
                rb.velocity = Vector3.Lerp(rb.velocity, Vector3.zero, decelSpeedOnGround * Time.deltaTime);
            }
        }
        void OnCollisionEnter(Collision collision)
        {
            rb.angularVelocity = Vector3.zero;
        }


        protected override void HandleRotations()
        {
            base.HandleRotations();

            Vector3 yawRef = desiredPlanarDirection.sqrMagnitude > 0.0001f
                ? desiredPlanarDirection
                : transform.forward;

            float targetYaw = Quaternion.LookRotation(yawRef, Vector3.up).eulerAngles.y;
            currentYaw = Mathf.LerpAngle(currentYaw, targetYaw, Time.deltaTime * turnResponsiveness);

            float targetBank = Mathf.Clamp(lastPlanarInput.x * bankAngleMax, -bankAngleMax, bankAngleMax);
            currentRoll = Mathf.Lerp(currentRoll, -targetBank, Time.deltaTime * bankReturnSpeed);

            if (autoForwardMovement)
            {
                currentPitch = pitchAmount;
            }
            else
            {
                float pitchVisual = Mathf.Lerp(0f, 10f, Mathf.Abs(lastPlanarInput.y));
                currentPitch = Mathf.Lerp(currentPitch, -Mathf.Sign(lastPlanarInput.y) * pitchVisual, Time.deltaTime * 3f);
            }

            Quaternion currentRotation = Quaternion.Euler(currentPitch, currentYaw, currentRoll);
            rb.MoveRotation(currentRotation);
        }

        protected override void UpdateMovement(IInputHandler inputHandler)
        {
            Transform reference = headingReference != null
                ? headingReference
                : (Camera.main != null ? Camera.main.transform : transform);

            Vector2 planarInput = new Vector2(inputHandler.Roll, inputHandler.Pitch);
            if (disableRoll)
            {
                planarInput.x = 0f;
            }
            if (disablePitch)
            {
                planarInput.y = 0f;
            }
            lastPlanarInput = planarInput;

            Vector3 camForward = reference.forward;
            camForward.y = 0f;
            if (camForward.sqrMagnitude < 0.0001f)
            {
                camForward = transform.forward;
            }
            camForward.Normalize();

            Vector3 camRight = reference.right;
            camRight.y = 0f;
            if (camRight.sqrMagnitude < 0.0001f)
            {
                camRight = transform.right;
            }
            camRight.Normalize();

            Vector3 desiredDir = camForward * planarInput.y + camRight * planarInput.x;
            if (desiredDir.sqrMagnitude > 0.0001f)
            {
                desiredDir.Normalize();
            }

            float inputMagnitude = Mathf.Clamp01(planarInput.magnitude);
            float targetSpeed = maxPlanarSpeed * inputMagnitude;
            Vector3 desiredPlanarVel = desiredDir * targetSpeed;

            if (autoForwardMovement)
            {
                Vector3 forwardPlanar = transform.forward;
                forwardPlanar.y = 0f;
                if (forwardPlanar.sqrMagnitude < 0.0001f)
                {
                    forwardPlanar = camForward;
                }
                forwardPlanar.Normalize();

                Vector3 autoVelocity = forwardPlanar * maxPlanarSpeed;
                Vector3 lateralVelocity = camRight * (planarInput.x * maxPlanarSpeed);
                desiredPlanarVel = autoVelocity + lateralVelocity;

                if (desiredPlanarVel.sqrMagnitude > maxPlanarSpeed * maxPlanarSpeed)
                {
                    desiredPlanarVel = desiredPlanarVel.normalized * maxPlanarSpeed;
                }

                desiredDir = desiredPlanarVel.sqrMagnitude > 0.0001f ? desiredPlanarVel.normalized : forwardPlanar;
                inputMagnitude = 1f;
            }

            desiredPlanarDirection = desiredDir;

            Vector3 velocity = rb.velocity;
            Vector3 planarVelocity = new Vector3(velocity.x, 0f, velocity.z);
            currentPlanarVelocity = planarVelocity;

            float accel = inputMagnitude > 0.05f ? acceleration : deceleration;
            Vector3 planarDelta = desiredPlanarVel - planarVelocity;
            Vector3 planarAccel = Vector3.ClampMagnitude(planarDelta, accel);

            if (maintainAltitude)
            {
                planarAccel.y = 0f;
            }

            rb.AddForce(planarAccel * rb.mass, ForceMode.Force);

            float forwardSpeed = Vector3.Dot(rb.velocity, transform.forward);
            if (!IsBoosting() &&
                Mathf.Abs(inputHandler.Pitch) >= quickStopInputThreshold &&
                ((forwardSpeed > 0f && inputHandler.Pitch < 0f) ||
                 (forwardSpeed < 0f && inputHandler.Pitch > 0f)))
            {
                rb.velocity -= Vector3.Project(rb.velocity, transform.forward);
            }

            Vector3 upVector = Vector3.up;
            upVector.x = 0f;
            upVector.z = 0f;

            float upVectorMagnitude = 1 - upVector.magnitude;
            float gravityMagnitude = Physics.gravity.magnitude * upVectorMagnitude;

            float upwardForce;

            if (!useGravityOnNoInput)
            {
                upwardForce = rb.mass * Physics.gravity.magnitude + gravityMagnitude + inputHandler.Lift * maxSpeed * verticalLiftScale;
            }
            else
            {
                upwardForce = inputHandler.Lift * maxSpeed * verticalLiftScale;
            }

            Vector3 liftForce = Vector3.up * upwardForce;

            if (enableHover && inputHandler.checkInputs)
            {
                timer += Time.deltaTime;
                float hoverForce = Mathf.Sin(timer * hoverFrequency) * hoverAmplitude;
                liftForce += Vector3.up * hoverForce;
            }

            rb.AddForce(liftForce, ForceMode.Force);
            AdjustDrag(rb.velocity.magnitude);
        }

        private bool IsBoosting()
        {
            return boostController != null && boostController.IsBoosting;
        }

        private void AdjustDrag(float speed)
        {
            // 速度に応じて抗力を線形補間
            rb.drag = Mathf.Lerp(baseDrag, maxDrag, speed / adjDragMaxSpeed);
        }

        public InputType GetInputType()
        {
            return inputType;
        }

        #region Input Helpers

        public void AddKeyboardInputs()
        {
            inputType = InputType.Keyboard;

            currentInputHandler = GetComponent<BaseInputHandler>();

            if (currentInputHandler != null)
            {
                GameObject mobileControls = GameObject.Find("Mobile Controls UI Holder");

                if (mobileControls != null)
                {
#if UNITY_EDITOR
                    DestroyImmediate(mobileControls);
#endif

                    if (Application.isPlaying)
                    {
                        Destroy(mobileControls);
                    }
                }

                DestroyImmediate(currentInputHandler);
            }

            InputHandler = gameObject.AddComponent<KeyboardInputHandler>();
            currentInputHandler = (BaseInputHandler)InputHandler;
        }

        public void AddMobileInputs()
        {
            inputType = InputType.Mobile;

            currentInputHandler = GetComponent<BaseInputHandler>();

            if (currentInputHandler != null)
            {
                DestroyImmediate(currentInputHandler);
            }

            GameObject mobileControls = GameObject.Find("Mobile Controls UI Holder");

            if (mobileControls == null)
            {
                mobileControls = Instantiate(Resources.Load<GameObject>("Mobile Controls UI Holder"), transform, true);
                mobileControls.name = "Mobile Controls UI Holder";
            }

            InputHandler = gameObject.AddComponent<MobileInputHandler>();
            currentInputHandler = (BaseInputHandler)InputHandler;

            MobileController[] controllers = GetComponentsInChildren<MobileController>();
            ((MobileInputHandler)InputHandler).SetMobileInputControllers(controllers);
        }

        public void AddMouseInputs()
        {
            inputType = InputType.Mouse;

            currentInputHandler = GetComponent<BaseInputHandler>();

            if (currentInputHandler != null)
            {
                GameObject mobileControls = GameObject.Find("Mobile Controls UI Holder");

                if (mobileControls != null)
                {
#if UNITY_EDITOR
                    DestroyImmediate(mobileControls);
#endif

                    if (Application.isPlaying)
                    {
                        Destroy(mobileControls);
                    }
                }

                DestroyImmediate(currentInputHandler);
            }

            InputHandler = gameObject.AddComponent<MouseInputHandler>();
            currentInputHandler = (BaseInputHandler)InputHandler;
        }

        #endregion
    }
}
