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

            Vector3 forwardForce =
                disablePitch ? Vector3.zero : inputHandler.Pitch * maxSpeed * transform.forward;
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
            AdjustDrag(rb.velocity.magnitude);
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