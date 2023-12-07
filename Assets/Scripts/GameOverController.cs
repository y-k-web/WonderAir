// GameOverController.cs

using UnityEngine;
using UnityEngine.SceneManagement;

public class GameOverController : MonoBehaviour
{
    public GameObject result; // ゲームオーバー画面のUIパネル
    public PlayerController playerController; // プレイヤーコントローラースクリプトへの参照

    void Start()
    {
        // ゲームオーバー画面を非表示にする
        result.SetActive(false);
        playerController = FindObjectOfType<PlayerController>(); // プレイヤーコントローラースクリプトへの参照を取得
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
         Debug.Log("title button clicked");
        SceneManager.LoadScene("FreeAir"); // タイトルシーン名に適切な名前を設定してください
    }
}
