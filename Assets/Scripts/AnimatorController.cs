using UnityEngine;

namespace RageRunGames.EasyFlyingSystem
{
    public class AnimatorController : MonoBehaviour
    {
        [SerializeField] private Animator animator;
        [SerializeField] private MobileController joystick;
        [SerializeField] private float joystickThreshold = 0.1f;

        private bool isFlying = false;
        private bool isColliding = false;

        private void Start()
        {
            if (animator == null)
            {
                animator = GetComponent<Animator>();
                if (animator == null)
                {
                    Debug.LogError("Animator not assigned or found!");
                }
            }

            if (joystick == null)
            {
                Debug.LogError("MobileController not assigned!");
            }
        }

        private void Update()
        {
            if (isColliding) return;

            float horizontal = joystick.Horizontal;
            float vertical = joystick.Vertical;
            Vector2 joystickInput = new Vector2(horizontal, vertical);

            bool isOperating = joystickInput.magnitude > joystickThreshold;

            if (isFlying != isOperating)
            {
                isFlying = isOperating;
                animator.SetBool("IsFlying", isFlying);
                Debug.Log($"Animator Bool 'IsFlying' set to: {isFlying}");
            }
        }

        private void OnCollisionEnter(Collision collision)
        {
            if (collision.collider.GetType() == typeof(TerrainCollider))
            {
                Debug.Log("Collision with Terrain detected.");
                
                if (IsInFlyingState())
                {
                    isColliding = true;

                    // 衝突アニメーションのトリガー
                    animator.SetTrigger("IsColliding");
                    Debug.Log("Animator Trigger 'Colliding' set.");

                    // 衝突状態を解除
                    Invoke(nameof(ResetCollisionState), 1.0f); // アニメーション長さに応じて調整
                }
            }
        }

        private bool IsInFlyingState()
        {
            AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);
            bool isFlyingState = stateInfo.IsName("Flying");
            Debug.Log($"IsInFlyingState: {isFlyingState}");
            return isFlyingState;
        }

        private void ResetCollisionState()
        {
            isColliding = false;
            Debug.Log("Collision state reset");
        }
    }
}
