using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;
using RageRunGames.EasyFlyingSystem; // DroneController を含む名前空間を追加

public class TimerController : MonoBehaviour
{
    public float timeLimit = 60.0f;
    private float currentTime;
    public TMP_Text timerTextVertical;   // 縦向きのときに表示するタイマー
    public TMP_Text timerTextHorizontal; // 横向きのときに表示するタイマー
    private float animationDuration = 1.0f;
    private float currentAnimationTime = 0f;
    private bool isGameOver = false; // ゲームオーバーフラグ
    public GameObject resultVertical; // 縦向きのときに表示するゲームオーバー画面
    public GameObject resultHorizontal; // 横向きのときに表示するゲームオーバー画面
    [SerializeField] private ScoreManager scoreManager; // ScoreManagerへの参照
    [SerializeField] private DroneController droneController; // DroneControllerへの参照

    void Start()
    {
        currentTime = timeLimit;
        UIHandler.Instance.RegisterOrientationObjects(timerTextVertical.gameObject, timerTextHorizontal.gameObject);

        if (scoreManager == null)
        {
            scoreManager = FindObjectOfType<ScoreManager>();
        }
    }

    void Update()
    {
        if (!isGameOver) // ゲームオーバーでない場合にのみ更新
        {
            currentTime -= Time.deltaTime;
            timerTextVertical.text = Mathf.Ceil(currentTime).ToString();
            timerTextHorizontal.text = Mathf.Ceil(currentTime).ToString();

            if (currentTime <= 10f)
            {
                timerTextVertical.color = Color.red;
                timerTextHorizontal.color = Color.red;

                currentAnimationTime += Time.deltaTime;
                float scaleValue = Mathf.PingPong(currentAnimationTime, animationDuration);
                Vector3 targetScale = Vector3.Lerp(new Vector3(1, 1, 1), new Vector3(1.5f, 1.5f, 1.5f), scaleValue / animationDuration);
                timerTextVertical.rectTransform.localScale = targetScale;
                timerTextHorizontal.rectTransform.localScale = targetScale;
            }
            else
            {
                timerTextVertical.color = Color.white;
                timerTextHorizontal.color = Color.white;

                timerTextVertical.rectTransform.localScale = new Vector3(1, 1, 1);
                timerTextHorizontal.rectTransform.localScale = new Vector3(1, 1, 1);
                currentAnimationTime = 0f;
            }

            if (currentTime <= 0)
            {
                GameOver(); // ゲームオーバー処理を呼び出す
            }
        }
    }

    public void AddTime(float amount)
    {
        currentTime += amount;
    }

    public void GameOver()
    {
        isGameOver = true; // ゲームオーバーフラグを設定

        // ゲームオーバー時のプレイヤーの操作を無効にする
        if (droneController != null)
        {
            droneController.enabled = false; // DroneController を無効にして動作を停止
        }
        else
        {
            Debug.LogWarning("DroneController reference is not set.");
        }

        UIHandler.Instance.RegisterOrientationObjects(resultVertical, resultHorizontal);

        scoreManager.UpdateGameOverScoreText();
        Debug.Log("GameOver method is called");
    }
}
