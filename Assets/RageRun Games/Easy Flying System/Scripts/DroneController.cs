using UnityEngine;

namespace RageRunGames.EasyFlyingSystem
{
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

        [Header("Hover Settings")] 
        [SerializeField] protected bool enableHover;

        [Range(0, 10)] [SerializeField] protected float hoverAmplitude = 1.25f;
        [Range(0, 10)] [SerializeField] protected float hoverFrequency = 2f;

        [Header("Quick Stop Settings")]
        [SerializeField] private float quickStopInputThreshold = 0.1f;

        [Header("Quick Slide Settings")]
        [SerializeField] private bool enableQuickSlide = true;
        [SerializeField, Range(0f, 1f)] private float quickSlideActivationPitchThreshold = 0.4f;
        [SerializeField, Range(0f, 1f)] private float quickSlideReleasePitchThreshold = 0.05f;
        [SerializeField, Range(0f, 1f)] private float quickSlideInputThreshold = 0.25f;
        [SerializeField] private float quickSlideWindowDuration = 0.25f;
        [SerializeField] private float quickSlideVelocityChange = 2f;
        [SerializeField] private float quickSlideDistance = 2f;
        [SerializeField] private float quickSlideMinForwardSpeed = 1f;

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
        private float previousPitchInput;
        private float quickSlideTimer;
        private bool quickSlideWindowActive;
        private bool quickSlideMovementActive;
        private float quickSlideMovementElapsed;
        private float quickSlideMovementDuration;
        private Vector3 quickSlideTargetOffset;
        private Vector3 quickSlideAppliedOffset;

        private BaseInputHandler currentInputHandler;
        private BoostController boostController;

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

            if (autoForwardMovement)
            {
                currentPitch = pitchAmount;
            }

            Quaternion currentRotation = Quaternion.Euler(currentPitch, currentYaw, currentRoll);
            rb.MoveRotation(currentRotation);
        }

        protected override void UpdateMovement(IInputHandler inputHandler)
        {
            Vector3 upVector = Vector3.up;
            upVector.x = 0f;
            upVector.z = 0f;

            float upVectorMagnitude = 1 - upVector.magnitude;
            float gravityMagnitude = Physics.gravity.magnitude * upVectorMagnitude;

            float upwardForce = 0f;

            if (!useGravityOnNoInput)
            {
                upwardForce = rb.mass * Physics.gravity.magnitude + gravityMagnitude + inputHandler.Lift * maxSpeed;
            }
            else
            {
                upwardForce = inputHandler.Lift * maxSpeed;
            }

            Vector3 liftForce = Vector3.up * upwardForce;

            float pitchInput = inputHandler.Pitch;
            Vector3 forwardForce =
                disablePitch ? Vector3.zero : pitchInput * maxSpeed * transform.forward;
            float forwardSpeed = Vector3.Dot(rb.velocity, transform.forward);

            HandleQuickSlide(pitchInput, inputHandler.Roll, forwardSpeed);

            if (!IsBoosting() &&
                Mathf.Abs(pitchInput) >= quickStopInputThreshold &&
                ((forwardSpeed > 0f && pitchInput < 0f) ||
                 (forwardSpeed < 0f && pitchInput > 0f)))
            {
                rb.velocity -= Vector3.Project(rb.velocity, transform.forward);
            }
            Vector3 sidewaysForce =
                disableRoll ? Vector3.zero : inputHandler.Roll * maxSpeed * transform.right;

            if (autoForwardMovement)
            {
                forwardForce = maxSpeed * transform.forward;
            }

            if (maintainAltitude)
            {
                forwardForce.y = 0f;
                sidewaysForce.y = 0f;
            }

            if (enableHover && inputHandler.checkInputs)
            {
                timer += Time.deltaTime;
                float hoverForce = Mathf.Sin(timer * hoverFrequency) * hoverAmplitude;
                liftForce += Vector3.up * hoverForce;
            }

            rb.AddForce(forwardForce + liftForce + sidewaysForce, ForceMode.Force);
            UpdateQuickSlideMovement();
            AdjustDrag(rb.velocity.magnitude);
            previousPitchInput = pitchInput;
        }

        private bool IsBoosting()
        {
            return boostController != null && boostController.IsBoosting;
        }

        private void HandleQuickSlide(float pitchInput, float rollInput, float forwardSpeed)
        {
            if (!enableQuickSlide)
            {
                quickSlideWindowActive = false;
                quickSlideTimer = 0f;
                return;
            }

            if (!quickSlideWindowActive)
            {
                bool wasMovingForward = previousPitchInput > quickSlideActivationPitchThreshold;
                bool hasReleasedForward = Mathf.Abs(pitchInput) <= quickSlideReleasePitchThreshold;
                bool isMovingForward = forwardSpeed > quickSlideMinForwardSpeed;

                if (wasMovingForward && hasReleasedForward && isMovingForward)
                {
                    quickSlideWindowActive = true;
                    quickSlideTimer = quickSlideWindowDuration;
                }
            }
            else
            {
                quickSlideTimer -= Time.deltaTime;

                if (quickSlideTimer <= 0f)
                {
                    quickSlideWindowActive = false;
                }
                else if (Mathf.Abs(rollInput) >= quickSlideInputThreshold)
                {
                    Vector3 slideDirection = Vector3.ProjectOnPlane(transform.right * Mathf.Sign(rollInput), Vector3.up);

                    if (slideDirection.sqrMagnitude > 0f)
                    {
                        StartQuickSlide(slideDirection.normalized);
                    }
                }
            }
        }

        private void StartQuickSlide(Vector3 slideDirection)
        {
            quickSlideWindowActive = false;

            if (quickSlideDistance <= 0f)
            {
                quickSlideMovementActive = false;
                return;
            }

            quickSlideTargetOffset = slideDirection * quickSlideDistance;
            quickSlideMovementDuration = quickSlideVelocityChange > Mathf.Epsilon
                ? quickSlideDistance / quickSlideVelocityChange
                : 0f;
            quickSlideMovementElapsed = 0f;
            quickSlideAppliedOffset = Vector3.zero;
            quickSlideMovementActive = true;
        }

        private void UpdateQuickSlideMovement()
        {
            if (!quickSlideMovementActive)
            {
                return;
            }

            float deltaTime = Time.deltaTime;

            if (quickSlideMovementDuration <= Mathf.Epsilon)
            {
                Vector3 remainingOffset = quickSlideTargetOffset - quickSlideAppliedOffset;

                if (remainingOffset.sqrMagnitude > 0f)
                {
                    rb.MovePosition(rb.position + remainingOffset);
                    quickSlideAppliedOffset += remainingOffset;
                }

                quickSlideMovementActive = false;
                return;
            }

            quickSlideMovementElapsed += deltaTime;
            float progress = Mathf.Clamp01(quickSlideMovementElapsed / quickSlideMovementDuration);
            Vector3 desiredOffset = quickSlideTargetOffset * progress;
            Vector3 offsetDelta = desiredOffset - quickSlideAppliedOffset;

            if (offsetDelta.sqrMagnitude > 0f)
            {
                rb.MovePosition(rb.position + offsetDelta);
                quickSlideAppliedOffset += offsetDelta;
            }

            if (progress >= 1f)
            {
                quickSlideMovementActive = false;
            }
        }

        private void AdjustDrag(float speed)
        {
            // 速度に応じて抗力を線形補間
            rb.drag = Mathf.Lerp(baseDrag, maxDrag, speed / adjDragMaxSpeed);

            // デバッグログ
            Debug.Log($"Speed: {speed}, Drag: {rb.drag}");
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
