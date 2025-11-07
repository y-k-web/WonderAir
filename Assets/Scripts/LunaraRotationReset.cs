using UnityEngine;

/// <summary>
/// Player配下のLunaraオブジェクトのローカルRotationを徐々に0へ戻す。
/// </summary>
public class LunaraRotationReset : MonoBehaviour
{
    [Tooltip("1秒間に戻る角度(度)。値が大きいほど早く0に戻ります。")]
    public float returnSpeed = 360f; // 1秒間に360度で元に戻す

    void Update()
    {
        // ローカル回転が0以外なら徐々にQuaternion.identityへ近づける
        if (transform.localRotation != Quaternion.identity)
        {
            transform.localRotation = Quaternion.RotateTowards(
                transform.localRotation,
                Quaternion.identity,
                returnSpeed * Time.deltaTime
            );
        }
    }
}

