using UnityEngine;
using UnityEngine.SceneManagement;

public class GameOverController : MonoBehaviour
{
    [Header("UI")]
    [SerializeField] private GameObject result; // ゲームオーバー画面UIパネル
    
    [Header("Player References")]
    [SerializeField] private PlayerController playerController;
    [SerializeField] private MobileInput mobileInput;
    [SerializeField] private BoostController boostController;

    void Start()
    {
        // 最初は非表示
        if (result != null)
            result.SetActive(false);

        // 自動取得（付け忘れ対策）
        if (playerController == null)  playerController = FindFirstObjectByType<PlayerController>();
        if (mobileInput == null)       mobileInput = FindFirstObjectByType<MobileInput>();
        if (boostController == null)   boostController = FindFirstObjectByType<BoostController>();
    }

    /// <summary>
    /// ゲームオーバー発火（敵衝突 / 落下 / HP0 などで呼ぶ）
    /// </summary>
    public void TriggerGameOver()
    {
        // UI 表示
        if (result != null)
            result.SetActive(true);

        // Player操作停止
        if (mobileInput != null)  mobileInput.enabled = false;
        if (playerController != null) playerController.enabled = false;
        if (boostController != null)  boostController.enabled = false;

        // 物理があるなら止める（任意）
        Rigidbody rb = playerController?.GetComponent<Rigidbody>();
        if (rb != null)
        {
            rb.velocity = Vector3.zero;
            rb.angularVelocity = Vector3.zero;
        }

        Debug.Log("=== GAME OVER ===");
    }

    /// <summary>
    /// リトライボタン
    /// </summary>
    public void Retry()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    /// <summary>
    /// タイトルへ戻る
    /// </summary>
    public void BackToTitle()
    {
        SceneManager.LoadScene("FreeAir");
    }
}
