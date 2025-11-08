using UnityEngine;
using UnityEngine.SceneManagement;

public class GameOverController : MonoBehaviour
{
    public GameObject result;                 // ゲームオーバーUI
    [SerializeField] private PlayerController player; // ここをPlayerControllerに

    void Start()
    {
        if (result) result.SetActive(false);
        if (player == null) player = FindFirstObjectByType<PlayerController>(FindObjectsInactive.Include);
    }

    public void ShowGameOver()
    {
        if (player) player.enabled = false;
        if (result) result.SetActive(true);
        Time.timeScale = 0f;
    }

    public void Retry()
    {
        Time.timeScale = 1f;
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    public void BackToTitle()
    {
        Time.timeScale = 1f;
        SceneManager.LoadScene("FreeAir"); // シーン名は実体に合わせて
    }
}
