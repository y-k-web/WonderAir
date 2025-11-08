using UnityEngine;

namespace WonderAir.Drone
{
    public class AnimatorController : MonoBehaviour
    {
        [SerializeField] private Animator animator;
        [SerializeField] private DroneController droneController;
        [SerializeField] private TouchInputHandler touchInputHandler;
        [SerializeField] private float inputThreshold = 0.2f;
        [SerializeField] private float velocityThreshold = 0.5f;

        private bool isFlying = false;
        private bool isColliding = false;

        private void Awake()
        {
            if (animator == null)
            {
                animator = GetComponent<Animator>();
                if (animator == null)
                {
                    Debug.LogError("Animator not assigned or found!");
                }
            }

            if (droneController == null)
            {
                droneController = GetComponentInParent<DroneController>();
                if (droneController == null)
                {
                    Debug.LogError("DroneController not assigned!");
                }
            }

            if (touchInputHandler == null && droneController != null)
            {
                touchInputHandler = droneController.GetComponent<TouchInputHandler>();
            }
        }

        private void Update()
        {
            if (isColliding || animator == null || droneController == null)
            {
                return;
            }

            bool hasInput = HasMovementInput();
            bool shouldFly = hasInput || HasMeaningfulVelocity();

            if (isFlying != shouldFly)
            {
                isFlying = shouldFly;
                animator.SetBool("IsFlying", isFlying);
            }
        }

        private bool HasMovementInput()
        {
            if (touchInputHandler != null && touchInputHandler.HasActiveInput)
            {
                return true;
            }

            var handler = droneController.InputHandler;
            if (handler == null)
            {
                return false;
            }

            return Mathf.Abs(handler.Pitch) > inputThreshold ||
                   Mathf.Abs(handler.Roll) > inputThreshold ||
                   Mathf.Abs(handler.Yaw) > inputThreshold ||
                   Mathf.Abs(handler.Lift) > inputThreshold;
        }

        private bool HasMeaningfulVelocity()
        {
            Rigidbody body = droneController.Rb;
            if (body == null)
            {
                return false;
            }

            return body.velocity.sqrMagnitude > velocityThreshold * velocityThreshold;
        }

        private void OnCollisionEnter(Collision collision)
        {
            if (collision.collider is TerrainCollider)
            {
                if (IsInFlyingState())
                {
                    isColliding = true;
                    animator.SetTrigger("IsColliding");
                    Invoke(nameof(ResetCollisionState), 1.0f);
                }
            }
        }

        private bool IsInFlyingState()
        {
            if (animator == null)
            {
                return false;
            }

            AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);
            return stateInfo.IsName("Flying");
        }

        private void ResetCollisionState()
        {
            isColliding = false;
        }
    }
}
