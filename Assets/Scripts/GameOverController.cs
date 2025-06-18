using UnityEngine;
using UnityEngine.SceneManagement;
using RageRunGames.EasyFlyingSystem; // DroneControllerが含まれているnamespaceを追加

public class GameOverController : MonoBehaviour
{
    public GameObject result; // ゲームオーバー画面のUIパネル
    public DroneController droneController; // DroneController への参照

    void Start()
    {
        // ゲームオーバー画面を非表示にする
        result.SetActive(false);

        // DroneController のインスタンスを取得
        droneController = FindObjectOfType<DroneController>();

        if (droneController == null)
        {
            Debug.LogError("DroneController が見つかりません。正しくアタッチされているか確認してください。");
        }
    }

    // リトライボタンがクリックされたときの処理
    public void Retry()
    {
        Debug.Log("Retry button clicked");
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    // タイトルに戻るボタンがクリックされたときの処理
    public void BackToTitle()
    {
        Debug.Log("Title button clicked");
        SceneManager.LoadScene("FreeAir"); // タイトルシーン名に適切な名前を設定してください
    }
}
