using UnityEngine;

public class KeyCollector : MonoBehaviour
{
    private TimerController timerController;
    private ScoreManager scoreManager; 

    private void Start()
    {
        // シーン内のUIManagerオブジェクトのUIHandlerスクリプトを探して取得
        GameObject uiManagerObject = GameObject.Find("UIManager");
        if (uiManagerObject != null)
        {
            timerController = uiManagerObject.GetComponent<TimerController>();
            scoreManager = FindObjectOfType<ScoreManager>();
        }
    }

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
