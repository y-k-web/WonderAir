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

        [Header("Engine Settings")]
        [SerializeField, Range(0f, 1f)] private float idleThrottle = 0.2f;
        [SerializeField] private float throttleChangeRate = 1.5f;
        [SerializeField] private float maxThrust = 180f;

        [Header("Aerodynamics")]
        [SerializeField] private float stallSpeed = 8f;
        [SerializeField] private float maxAngleOfAttack = 25f;
        [SerializeField] private float liftPower = 0.5f;
        [SerializeField] private float dragFactor = 0.02f;
        [SerializeField] private float inducedDragFactor = 0.015f;
        [SerializeField] private float angularDamping = 0.8f;
        [SerializeField] private float bankTorqueStrength = 4f;
        [SerializeField] private AnimationCurve liftCurve =
            new AnimationCurve(
                new Keyframe(0f, 0f, 0f, 2f),
                new Keyframe(0.5f, 1f, 0f, 0f),
                new Keyframe(1f, 0f, -2f, 0f));

        [Header("Ground Settings")]
        [SerializeField] protected float groundCheckDistance = 0.2f;
        [SerializeField] protected bool decelerateOnGround;
        [SerializeField] protected float decelSpeedOnGround = 4f;


        private float throttle;
        private float targetThrottle;

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
            rb.useGravity = true;
            rb.drag = dragFactor;
            rb.angularDrag = angularDamping;

            throttle = Mathf.Clamp01(idleThrottle);
            targetThrottle = throttle;
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

            Quaternion currentRotation = Quaternion.Euler(currentPitch, currentYaw, currentRoll);
            rb.MoveRotation(currentRotation);
        }

        protected override void UpdateMovement(IInputHandler inputHandler)
        {
            UpdateThrottle(inputHandler.Lift);

            Vector3 velocity = rb.velocity;
            float speed = velocity.magnitude;
            Vector3 forward = transform.forward;
            Vector3 up = transform.up;

            float forwardSpeed = Mathf.Max(0f, Vector3.Dot(velocity, forward));

            Vector3 thrustForce = forward * (maxThrust * throttle);

            Vector3 velocityDirection = speed > 0.01f ? velocity.normalized : forward;
            float angleOfAttack = Vector3.SignedAngle(forward, velocityDirection, transform.right);
            float normalizedAoA = Mathf.InverseLerp(-maxAngleOfAttack, maxAngleOfAttack, angleOfAttack);
            float liftEvaluation = liftCurve.Evaluate(Mathf.Clamp01(normalizedAoA));

            float liftMagnitude = liftPower * liftEvaluation * forwardSpeed * forwardSpeed;

            if (forwardSpeed < stallSpeed)
            {
                float stallFactor = Mathf.Clamp01(forwardSpeed / Mathf.Max(0.1f, stallSpeed));
                liftMagnitude *= stallFactor * stallFactor;
            }

            Vector3 liftForce = up * liftMagnitude;

            Vector3 dragForce = Vector3.zero;

            if (speed > 0.01f)
            {
                dragForce = -velocityDirection * (dragFactor * speed * speed);
            }

            Vector3 inducedDrag = -forward * (liftMagnitude * inducedDragFactor);

            Vector3 bankTorque = Vector3.zero;

            if (!Mathf.Approximately(speed, 0f))
            {
                float bankAmount = Mathf.Sin(Mathf.Deg2Rad * currentRoll);
                bankTorque = transform.up * (bankAmount * bankTorqueStrength * speed);
            }

            rb.AddForce(thrustForce + liftForce + dragForce + inducedDrag, ForceMode.Force);
            rb.AddTorque(bankTorque - rb.angularVelocity * angularDamping, ForceMode.Force);

            LimitVelocity(velocity);
        }

        private void UpdateThrottle(float liftInput)
        {
            if (autoForwardMovement)
            {
                targetThrottle = 1f;
            }
            else
            {
                targetThrottle = Mathf.Clamp01(targetThrottle + liftInput * throttleChangeRate * Time.fixedDeltaTime);
                targetThrottle = Mathf.Max(targetThrottle, idleThrottle);
            }

            throttle = Mathf.MoveTowards(throttle, targetThrottle, throttleChangeRate * Time.fixedDeltaTime);
        }

        private void LimitVelocity(Vector3 velocity)
        {
            Vector3 localVelocity = transform.InverseTransformDirection(velocity);
            localVelocity.z = Mathf.Clamp(localVelocity.z, 0f, maxSpeed);
            float lateralLimit = maxSpeed * 0.35f;
            localVelocity.x = Mathf.Clamp(localVelocity.x, -lateralLimit, lateralLimit);
            localVelocity.y = Mathf.Clamp(localVelocity.y, -lateralLimit, lateralLimit);

            rb.velocity = transform.TransformDirection(localVelocity);
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