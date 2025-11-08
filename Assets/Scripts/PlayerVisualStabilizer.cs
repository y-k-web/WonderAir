using UnityEngine;

public class PlayerVisualStabilizer : MonoBehaviour
{
    [Header("Refs")]
    public Transform root;     // Player 本体（Yawのみ）
    public Transform visual;   // 見た目（Animatorが付く子）

    [Header("Banks & Pitch")]
    public float maxBankDegrees   = 35f;  // 旋回時の傾き
    public float maxPitchDegrees  = 20f;  // 上下入力の傾き
    public float bankResponse     = 8f;   // バンク追従の速さ
    public float pitchResponse    = 8f;   // ピッチ追従の速さ
    public float autoLevelSpeed   = 3f;   // 入力ゼロ時の水平復帰

    // 入力は外部(PlayerController)から渡す
    [HideInInspector] public float yawInput;    // -1..1 (左右ドラッグ)
    [HideInInspector] public float pitchInput;  // -1..1 (上下ドラッグ)

    void LateUpdate()
    {
        if (!root || !visual) return;

        // rootのYawだけで視線方向を作る
        var rootYawOnly = Quaternion.Euler(0f, root.eulerAngles.y, 0f);

        // 目標Roll/Pitchを入力から作る（入力が無ければ0へ）
        float targetBank  = Mathf.LerpAngle(GetRoll(visual),  0f, Time.deltaTime * autoLevelSpeed);
        float targetPitch = Mathf.LerpAngle(GetPitch(visual), 0f, Time.deltaTime * autoLevelSpeed);

        if (Mathf.Abs(yawInput) > 0.001f)
            targetBank = -yawInput * maxBankDegrees;  // 右旋回で右に倒れる（-で好み反転）
        if (Mathf.Abs(pitchInput) > 0.001f)
            targetPitch =  pitchInput * maxPitchDegrees;

        // 現在のRoll/Pitchを目標へスムーズに寄せる
        float nextRoll  = Mathf.LerpAngle(GetRoll(visual),  targetBank,  Time.deltaTime * bankResponse);
        float nextPitch = Mathf.LerpAngle(GetPitch(visual), targetPitch, Time.deltaTime * pitchResponse);

        // visualの最終回転 = rootのYaw をベースに Pitch/Bank を付与（Bank=Z回転）
        Quaternion bankQ  = Quaternion.AngleAxis(nextRoll,  Vector3.forward);
        Quaternion pitchQ = Quaternion.AngleAxis(nextPitch, Vector3.right);
        visual.rotation = rootYawOnly * pitchQ * bankQ;
    }

    float GetRoll(Transform t)
    {
        var z = t.eulerAngles.z; if (z > 180f) z -= 360f; return z;
    }
    float GetPitch(Transform t)
    {
        var x = t.eulerAngles.x; if (x > 180f) x -= 360f; return x;
    }
}
