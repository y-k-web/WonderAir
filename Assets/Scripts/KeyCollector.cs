using UnityEngine;

public class KeyCollector : MonoBehaviour
{
    [SerializeField] private TimerController timerController;
    [SerializeField] private ScoreManager scoreManager;
    [SerializeField] private float keyTimeBonus = 60f; // Time added when a key is collected

    private void Awake()
    {
        if (timerController == null)
        {
            timerController = FindObjectOfType<TimerController>();
        }

        if (scoreManager == null)
        {
            scoreManager = FindObjectOfType<ScoreManager>();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            if (timerController != null)
            {
                timerController.AddTime(keyTimeBonus);  // タイマーにx秒を追加
            }

            if (scoreManager != null)
            {
                scoreManager.CollectKey();  // ScoreManager内のCollectKeyメソッドを呼び出す
            }

            // Destroy(gameObject); // Keyオブジェクトを破棄
        }
    }
}
