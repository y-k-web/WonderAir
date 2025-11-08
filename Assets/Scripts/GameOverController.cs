using UnityEngine;
using UnityEngine.SceneManagement;

public class GameOverController : MonoBehaviour
{
    public GameObject result; // ゲームオーバー画面のUIパネル

    void Start()
    {

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
