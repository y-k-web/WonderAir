using UnityEngine;
using TMPro;

public class TimerController : MonoBehaviour
{
    [Header("Time")]
    public float timeLimit = 60.0f;
    private float currentTime;
    private float animationDuration = 1.0f;
    private float currentAnimationTime = 0f;
    private bool isGameOver = false;

    [Header("UI")]
    public TMP_Text timerTextVertical;      // 縦向き表示
    public TMP_Text timerTextHorizontal;    // 横向き表示
    public GameObject resultVertical;       // 縦向きのリザルト
    public GameObject resultHorizontal;     // 横向きのリザルト

    [Header("Refs")]
    [SerializeField] private ScoreManager scoreManager;     // 任意でインスペクタ割り当て
    [SerializeField] private PlayerController playerController; // 任意でインスペクタ割り当て

    private void Awake()
    {
        // 参照が未設定なら探す（Unityバージョン差分に対応）
#if UNITY_6000_0_OR_NEWER
        if (scoreManager == null)
            scoreManager = FindFirstObjectByType<ScoreManager>(FindObjectsInactive.Include);
        if (playerController == null)
            playerController = FindFirstObjectByType<PlayerController>(FindObjectsInactive.Include);
#else
        if (scoreManager == null)
            scoreManager = FindObjectOfType<ScoreManager>(true);
        if (playerController == null)
            playerController = FindObjectOfType<PlayerController>(true);
#endif
    }

    private void Start()
    {
        currentTime = timeLimit;

        // 向き切り替えの登録（存在チェック付き）
        if (UIHandler.Instance != null)
            UIHandler.Instance.RegisterOrientationObjects(timerTextVertical?.gameObject, timerTextHorizontal?.gameObject);

        // リザルトは開始時は非表示に
        if (resultVertical) resultVertical.SetActive(false);
        if (resultHorizontal) resultHorizontal.SetActive(false);
    }

    private void Update()
    {
        if (isGameOver) return;

        currentTime -= Time.deltaTime;
        var remain = Mathf.Ceil(currentTime);
        if (timerTextVertical)   timerTextVertical.text   = remain.ToString();
        if (timerTextHorizontal) timerTextHorizontal.text = remain.ToString();

        // 10秒以下で点滅＆赤色
        if (currentTime <= 10f)
        {
            if (timerTextVertical)   timerTextVertical.color   = Color.red;
            if (timerTextHorizontal) timerTextHorizontal.color = Color.red;

            currentAnimationTime += Time.deltaTime;
            float t = Mathf.PingPong(currentAnimationTime, animationDuration) / animationDuration;
            Vector3 scale = Vector3.Lerp(Vector3.one, new Vector3(1.5f, 1.5f, 1f), t);

            if (timerTextVertical)   timerTextVertical.rectTransform.localScale   = scale;
            if (timerTextHorizontal) timerTextHorizontal.rectTransform.localScale = scale;
        }
        else
        {
            if (timerTextVertical)
            {
                timerTextVertical.color = Color.white;
                timerTextVertical.rectTransform.localScale = Vector3.one;
            }
            if (timerTextHorizontal)
            {
                timerTextHorizontal.color = Color.white;
                timerTextHorizontal.rectTransform.localScale = Vector3.one;
            }
            currentAnimationTime = 0f;
        }

        if (currentTime <= 0f)
            GameOver();
    }

    public void AddTime(float amount)
    {
        currentTime = Mathf.Max(0f, currentTime + amount);
    }

    public void GameOver()
    {
        if (isGameOver) return;
        isGameOver = true;

        // プレイヤー操作を停止
        if (playerController != null)
            playerController.enabled = false;

        // リザルトUIの向き切替に登録＆表示
        if (UIHandler.Instance != null)
            UIHandler.Instance.RegisterOrientationObjects(resultVertical, resultHorizontal);
        if (resultVertical)   resultVertical.SetActive(true);
        if (resultHorizontal) resultHorizontal.SetActive(true);

        // スコア更新
        if (scoreManager != null)
            scoreManager.UpdateGameOverScoreText();

        Debug.Log("GameOver");
    }
}
