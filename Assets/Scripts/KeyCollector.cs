using UnityEngine;

public class KeyCollector : MonoBehaviour
{
    [SerializeField] private TimerController timerController;
    [SerializeField] private ScoreManager scoreManager;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            if (timerController != null)
            {
                timerController.AddTime(60f);  // タイマーにx秒を追加
            }

            if (scoreManager != null)
            {
                scoreManager.CollectKey();  // ScoreManager内のCollectKeyメソッドを呼び出す
            }

            // Destroy(gameObject); // Keyオブジェクトを破棄
        }
    }
}
