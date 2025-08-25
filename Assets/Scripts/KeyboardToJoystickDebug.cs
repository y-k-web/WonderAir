using UnityEngine;

namespace RageRunGames.EasyFlyingSystem
{
    [DisallowMultipleComponent]
    public class KeyboardToJoystickDebug : MonoBehaviour
    {
        [SerializeField] private MobileController mobileController; // MobileControllerの参照
        [SerializeField] private bool enableDebugInput = true;      // デバッグ入力を有効化
        [SerializeField] private bool enableHorizontalInput = true; // 水平軸の入力を有効化

        private bool wasKeyboardInput = false; // 前フレームでキーボード入力があったか
        private Vector2 lastKeyboardVector = Vector2.zero; // 前回適用したキーボード入力

        private void Start()
        {
            // MobileController の参照を自動取得
            if (mobileController == null)
            {
                mobileController = GetComponent<MobileController>();
                if (mobileController == null)
                {
                    Debug.LogError("MobileController is not assigned or attached to this GameObject.");
                }
            }
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

            if (hasInput)
            {
                Vector2 mobileInput = mobileController.CurrentInput - lastKeyboardVector;
                Vector2 keyboardVector = new Vector2(horizontalInput, verticalInput);
                lastKeyboardVector = keyboardVector;
                Vector2 combined = Vector2.ClampMagnitude(mobileInput + keyboardVector, 1f);
                mobileController.SetDebugInput(combined);
                wasKeyboardInput = true;
            }
            else if (wasKeyboardInput)
            {
                Vector2 mobileInput = mobileController.CurrentInput - lastKeyboardVector;
                mobileController.SetDebugInput(mobileInput);
                lastKeyboardVector = Vector2.zero;
                wasKeyboardInput = false;
            }
        }
    }
}
