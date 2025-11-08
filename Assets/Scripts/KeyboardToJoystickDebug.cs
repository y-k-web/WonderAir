using UnityEngine;

namespace RageRunGames.EasyFlyingSystem
{
    [DisallowMultipleComponent]
    public class KeyboardToJoystickDebug : MonoBehaviour
    {
        [SerializeField] private bool enableDebugInput = true;      // デバッグ入力を有効化
        [SerializeField] private bool enableHorizontalInput = true; // 水平軸の入力を有効化
        private bool wasKeyboardInput = false; // 前フレームでキーボード入力があったか
        private Vector2 lastAppliedKeyboardVector = Vector2.zero; // 前回適用したキーボード入力の寄与分

        private void Start()
        {

        }

        private void Update()
        {
            if (!enableDebugInput || mobileController == null)
                return;

            // キーボード入力を取得
            float verticalInput = 0f;
            float horizontalInput = 0f;
            bool hasInput = false;

            if (Input.GetKey(KeyCode.W))
            {
                verticalInput += 1f;
                hasInput = true;
            }
            if (Input.GetKey(KeyCode.S))
            {
                verticalInput -= 1f;
                hasInput = true;
            }

            if (enableHorizontalInput)
            {
                if (Input.GetKey(KeyCode.D))
                {
                    horizontalInput += 1f;
                    hasInput = true;
                }
                if (Input.GetKey(KeyCode.A))
                {
                    horizontalInput -= 1f;
                    hasInput = true;
                }
            }

            Vector2 baseInput = CurrentInput - lastAppliedKeyboardVector;

            if (hasInput)
            {
                Vector2 keyboardVector = new Vector2(horizontalInput, verticalInput);
                Vector2 combined = Vector2.ClampMagnitude(baseInput + keyboardVector, 1f);
                lastAppliedKeyboardVector = combined - baseInput;
                wasKeyboardInput = true;
            }
            else if (wasKeyboardInput)
            {
                lastAppliedKeyboardVector = Vector2.zero;
                wasKeyboardInput = false;
            }
        }
    }
}
