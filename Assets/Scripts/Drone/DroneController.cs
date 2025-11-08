using UnityEngine;

namespace WonderAir.Drone
{
    [DisallowMultipleComponent]
    [RequireComponent(typeof(Rigidbody))]
    [RequireComponent(typeof(BoxCollider))]
    public class DroneController : BaseFlyController
    {
        [Header("Input Settings")]
        [HideInInspector] public InputType inputType = InputType.Mobile;

        [Header("Controller Settings")]
        [SerializeField] private bool maintainAltitude = true;
        [SerializeField] protected bool useGravityOnNoInput;

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

        [Header("Inertia Settings")]
        [SerializeField] private float baseDrag = 1f;
        [SerializeField] private float maxDrag = 1.5f;
        [SerializeField] private float adjDragMaxSpeed = 20f;

        private float timer;

        private CompositeInput compositeInput;
        private KeyboardInputHandler keyboardInput;
        private TouchInputHandler touchInput;
        private BoostController boostController;

        public bool IsGrounded { get; private set; } = true;

        protected override void Initialize()
        {
            base.Initialize();

            keyboardInput = GetComponent<KeyboardInputHandler>();
            touchInput = GetComponent<TouchInputHandler>();
            boostController = GetComponent<BoostController>();

            compositeInput = new CompositeInput(this, keyboardInput, touchInput);
            InputHandler = compositeInput;

            if (rb != null)
            {
                rb.drag = baseDrag;
            }
        }

        protected override void Update()
        {
            IsGrounded = Physics.Raycast(transform.position, Vector3.down, groundCheckDistance);

            if (IsGrounded && rb.velocity != Vector3.zero && decelerateOnGround)
            {
                rb.velocity = Vector3.Lerp(rb.velocity, Vector3.zero, decelSpeedOnGround * Time.deltaTime);
            }

            base.Update();
        }

        protected override void UpdateMovement(IInputHandler inputHandler)
        {
            Vector3 upVector = Vector3.up;
            upVector.x = 0f;
            upVector.z = 0f;

            float upVectorMagnitude = 1 - upVector.magnitude;
            float gravityMagnitude = Physics.gravity.magnitude * upVectorMagnitude;

            float upwardForce;

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

            if (!IsBoosting() &&
                Mathf.Abs(pitchInput) >= quickStopInputThreshold &&
                ((forwardSpeed > 0f && pitchInput < 0f) ||
                 (forwardSpeed < 0f && pitchInput > 0f)))
            {
                rb.velocity -= Vector3.Project(rb.velocity, transform.forward);
            }

            Vector3 sidewaysForce =
                disableRoll ? Vector3.zero : inputHandler.Roll * maxSpeed * transform.right;

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
            else if (!enableHover)
            {
                timer = 0f;
            }

            rb.AddForce(forwardForce + liftForce + sidewaysForce, ForceMode.Force);
            AdjustDrag(rb.velocity.magnitude);
        }

        private bool IsBoosting()
        {
            return boostController != null && boostController.IsBoosting;
        }

        private void AdjustDrag(float speed)
        {
            rb.drag = Mathf.Lerp(baseDrag, maxDrag, speed / adjDragMaxSpeed);
        }

        public InputType GetInputType()
        {
            return inputType;
        }

        private class CompositeInput : IInputHandler
        {
            private readonly DroneController controller;
            private readonly KeyboardInputHandler keyboard;
            private readonly TouchInputHandler touch;

            public float Pitch { get; set; }
            public float Roll { get; set; }
            public float Yaw { get; set; }
            public float Lift { get; set; }
            public bool checkInputs { get; set; }

            public CompositeInput(DroneController controller, KeyboardInputHandler keyboard, TouchInputHandler touch)
            {
                this.controller = controller;
                this.keyboard = keyboard;
                this.touch = touch;
            }

            public void HandleInputs()
            {
                keyboard?.HandleInputs();
                touch?.HandleInputs();

                bool useTouch = touch != null && touch.HasActiveInput;

                if (useTouch)
                {
                    Pitch = touch.Pitch;
                    Roll = touch.Roll;
                    Yaw = touch.Yaw;
                    Lift = touch.Lift;
                    controller.inputType = InputType.Mobile;
                }
                else
                {
                    Pitch = keyboard != null ? keyboard.Pitch : 0f;
                    Roll = keyboard != null ? keyboard.Roll : 0f;
                    Yaw = keyboard != null ? keyboard.Yaw : 0f;
                    Lift = keyboard != null ? keyboard.Lift : 0f;
                    controller.inputType = InputType.Keyboard;
                }

                checkInputs = Mathf.Abs(Pitch) <= 0.05f &&
                              Mathf.Abs(Roll) <= 0.05f &&
                              Mathf.Abs(Yaw) <= 0.05f &&
                              Mathf.Abs(Lift) <= 0.05f;
            }
        }
    }
}
