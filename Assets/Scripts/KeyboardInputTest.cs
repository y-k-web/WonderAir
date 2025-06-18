using UnityEngine;

public class KeyboardInputTest : MonoBehaviour
{
    void Update()
    {
        // キーボード入力を取得
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        // デバッグログで確認
        Debug.Log($"Horizontal Input: {horizontal}, Vertical Input: {vertical}");

        // 入力が取得されていない場合の警告
        if (Mathf.Approximately(horizontal, 0f) && Mathf.Approximately(vertical, 0f))
        {
            Debug.LogWarning("No keyboard input detected!");
        }
    }
}
