using UnityEngine;

namespace RageRunGames.EasyFlyingSystem
{
    public class BaseFlyController : MonoBehaviour
    {
        [Header("Engine Settings")] 
        [SerializeField] public float maxSpeed = 20;
        [SerializeField] protected bool autoForwardMovement;
        
        [Header("Controller Settings")] 
        [SerializeField] protected float pitchAmount = 30f;
        [SerializeField] protected float rollAmount = 30f;
        [SerializeField] protected float yawAmount = 4f;
        
        [SerializeField] protected float rotationLerpSpeed = 2f;
        
        [Header("Rotation Settings")] 
        [SerializeField] protected bool disableYaw;
        [SerializeField] protected bool disablePitch;
        [SerializeField] protected bool disableRoll;
        
        [Header("Rotation Limits")] 
        [SerializeField] protected bool ignoreRotationLimits; 
        [SerializeField] protected Vector2 pitchRotationLimit = new Vector2(-30f, 30f);
        [SerializeField] protected Vector2 rollRotationLimit = new Vector2(-30f, 30f);

        protected Rigidbody rb;
        public Rigidbody Rb => rb;
        
        public IInputHandler InputHandler { get; protected set; }
        
        protected float currentPitch;
        protected float currentRoll;
        protected float currentYaw;
        protected float yaw;
        
        private void Start()
        {
            Initialize();
        }

        protected virtual void Initialize()
        {
            rb = GetComponent<Rigidbody>();

            rb.drag = 0.6f;
            rb.interpolation = RigidbodyInterpolation.Interpolate;
            rb.collisionDetectionMode = CollisionDetectionMode.Continuous;

            if (disablePitch)
            {
                rb.constraints &=
                    RigidbodyConstraints.FreezePositionZ;
                rb.freezeRotation = true;
            }

            if (disableRoll)
            {
                rb.constraints &=
                    RigidbodyConstraints.FreezePositionX;
                rb.freezeRotation = true;
            }

            InputHandler = GetComponent<IInputHandler>();
        }
        
        protected virtual void Update()
        {
            InputHandler.HandleInputs();
        }

        protected virtual void FixedUpdate()
        {
            HandleThrottle();
            HandleRotations();
        }

        private void HandleThrottle()
        {
            UpdateMovement(InputHandler);
        }
        
        protected virtual void HandleRotations()
        {
            float pitch = InputHandler.Pitch * pitchAmount;
            float roll = -InputHandler.Roll * rollAmount;
            yaw += InputHandler.Yaw * yawAmount;

            currentPitch = disablePitch ? 0f : SmoothLerpValue(currentPitch, pitch, rotationLerpSpeed);
            currentRoll = disableRoll ? 0f : SmoothLerpValue(currentRoll, roll, rotationLerpSpeed);
            currentYaw = disableYaw ? 0f : SmoothLerpValue(currentYaw, yaw, rotationLerpSpeed);

            if (!ignoreRotationLimits)
            {
                currentPitch = Mathf.Clamp(currentPitch, pitchRotationLimit.x, pitchRotationLimit.y);
                currentRoll = Mathf.Clamp(currentRoll, rollRotationLimit.x, rollRotationLimit.y);
            }
        }
        

        protected virtual void UpdateMovement(IInputHandler inputHandler)
        {
          
        }

        protected float SmoothLerpValue(float final, float current, float lerpSpeed)
        {
            return Mathf.Lerp(final, current, lerpSpeed * Time.fixedDeltaTime);
        }
    }
}