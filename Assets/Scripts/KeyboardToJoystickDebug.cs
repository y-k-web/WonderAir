using UnityEngine;

namespace RageRunGames.EasyFlyingSystem
{
    [DisallowMultipleComponent]
    public class KeyboardToJoystickDebug : MonoBehaviour
    {
        [SerializeField] private MobileController mobileController; // MobileControllerの参照
        [SerializeField] private bool enableDebugInput = true;      // デバッグ入力を有効化
        [SerializeField] private bool enableHorizontalInput = true; // 水平軸の入力を有効化

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

            // キーボードの垂直入力を取得 (W/S)
            float verticalInput = 0f;
            if (Input.GetKey(KeyCode.W))
                verticalInput += 1f;
            if (Input.GetKey(KeyCode.S))
                verticalInput -= 1f;

            // 水平軸が有効な場合のみキーボードの水平入力を取得 (A/D)
            float horizontalInput = 0f;
            if (enableHorizontalInput)
            {
                if (Input.GetKey(KeyCode.D))
                    horizontalInput += 1f;
                if (Input.GetKey(KeyCode.A))
                    horizontalInput -= 1f;
            }

            // MobileControllerに入力を適用
            ApplyKeyboardInputToJoystick(horizontalInput, verticalInput);
        }

        private void ApplyKeyboardInputToJoystick(float horizontal, float vertical)
        {
            // 入力ベクトルを作成
            Vector2 inputVector = new Vector2(horizontal, vertical);
            inputVector = Vector2.ClampMagnitude(inputVector, 1f); // 入力値を正規化

            // MobileControllerにデバッグ入力を設定
            mobileController.SetDebugInput(inputVector);

            // デバッグログで確認
            Debug.Log($"Horizontal Input: {horizontal}, Vertical Input: {vertical}");
        }
    }
}
