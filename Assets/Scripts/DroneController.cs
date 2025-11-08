using UnityEngine;

namespace RageRunGames.EasyFlyingSystem
{
    /// <summary>
    /// Basic drone style movement controller that moves using input provided by <see cref="MobileController"/>.
    /// The implementation is intentionally lightweight so the gameplay scripts in this project can reference it
    /// without depending on external packages.
    /// </summary>
    [RequireComponent(typeof(Rigidbody))]
    [DisallowMultipleComponent]
    public class DroneController : MonoBehaviour
    {
        [Header("Movement")]
        [SerializeField] private float defaultMaxSpeed = 8f;
        [SerializeField] private float acceleration = 12f;
        [SerializeField] private float rotationSpeed = 6f;
        [SerializeField] private float verticalLiftSpeed = 3f;
        [SerializeField] private bool enableVerticalInput = false;

        [Header("Dependencies")]
        [SerializeField] private MobileController mobileController;

        private Rigidbody cachedRigidbody;

        /// <summary>
        /// Publicly adjustable maximum speed. Boost systems modify this value directly.
        /// </summary>
        public float maxSpeed { get; set; }

        private void Awake()
        {
            cachedRigidbody = GetComponent<Rigidbody>();
            cachedRigidbody.useGravity = !enableVerticalInput;

            if (mobileController == null)
            {
                mobileController = GetComponent<MobileController>();
            }

            maxSpeed = defaultMaxSpeed;
        }

        private void FixedUpdate()
        {
            Vector2 input = GetInput();
            ApplyMovement(input);
            ApplyRotation(input);
        }

        private Vector2 GetInput()
        {
            if (mobileController != null)
            {
                return mobileController.CurrentInput;
            }

            return new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
        }

        private void ApplyMovement(Vector2 input)
        {
            Vector3 desired = new Vector3(input.x, 0f, input.y) * maxSpeed;
            Vector3 velocity = cachedRigidbody.velocity;
            Vector3 horizontal = new Vector3(velocity.x, 0f, velocity.z);

            Vector3 newHorizontal = Vector3.MoveTowards(horizontal, desired, acceleration * Time.fixedDeltaTime);
            float verticalVelocity = velocity.y;

            if (enableVerticalInput)
            {
                verticalVelocity = Mathf.MoveTowards(verticalVelocity, input.y * verticalLiftSpeed, acceleration * Time.fixedDeltaTime);
            }

            cachedRigidbody.velocity = new Vector3(newHorizontal.x, verticalVelocity, newHorizontal.z);
        }

        private void ApplyRotation(Vector2 input)
        {
            Vector3 planar = new Vector3(input.x, 0f, input.y);
            if (planar.sqrMagnitude < 0.0001f)
            {
                return;
            }

            Quaternion targetRotation = Quaternion.LookRotation(planar.normalized, Vector3.up);
            cachedRigidbody.MoveRotation(Quaternion.Slerp(cachedRigidbody.rotation, targetRotation, rotationSpeed * Time.fixedDeltaTime));
        }

        private void OnDisable()
        {
            // Ensure the drone stops immediately when the controller is disabled.
            cachedRigidbody.velocity = Vector3.zero;
        }
    }
}
