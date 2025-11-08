using UnityEngine;
using UnityEngine.UI;

public class BoostController : MonoBehaviour
{
    [Header("UI (任意)")]
    [SerializeField] private Slider boostBarVertical;     // 縦用ゲージ（任意）
    [SerializeField] private Slider boostBarHorizontal;   // 横用ゲージ（任意）
    [SerializeField] private Button boostButtonVertical;  // 縦用ボタン（任意：タップBoost併用可）
    [SerializeField] private Button boostButtonHorizontal;// 横用ボタン（任意）

    [Header("ブースト設定")]
    [SerializeField] private float maxBoost = 100f;            // ゲージ最大
    [SerializeField] private float boostConsumptionRate = 20f; // 消費/秒
    [SerializeField] private float boostRechargeRate = 10f;    // 回復/秒
    [SerializeField] private float boostSpeedMultiplier = 2.0f;// Boost中の速度倍率

    [Header("演出（任意）")]
    [SerializeField] private ParticleSystem leftHandParticle;
    [SerializeField] private ParticleSystem rightHandParticle;
    [SerializeField] private TrailRenderer leftTrail;
    [SerializeField] private TrailRenderer rightTrail;

    [Header("入力参照")]
    [SerializeField] private MobileInput mobileInput; // ← タップBoostをここから受け取る( boost: bool )

    // 外部が読むための現在倍率（PlayerController側で speed * CurrentSpeedMultiplier して使う）
    public float CurrentSpeedMultiplier => isBoosting ? boostSpeedMultiplier : 1f;
    public bool IsBoosting => isBoosting;

    private float currentBoost;
    private bool isBoosting;
    private bool forceToggleFromUIButton; // UIボタンで手動ON/OFFしたい場合に使う

    private Color leftOriginalColor;
    private Color rightOriginalColor;

    void Awake()
    {
        currentBoost = maxBoost;

        if (mobileInput == null)
        {
            mobileInput = FindFirstObjectByType<MobileInput>();
        }

        // 任意：UIボタンでトグル（無ければ無視）
        if (boostButtonVertical != null)   boostButtonVertical.onClick.AddListener(ToggleBoostManual);
        if (boostButtonHorizontal != null) boostButtonHorizontal.onClick.AddListener(ToggleBoostManual);

        // 既存UI切替を使っているなら登録（無ければ無視）
        if (UIHandler.Instance != null)
        {
            UIHandler.Instance.RegisterOrientationObjects(boostBarVertical?.gameObject, boostBarHorizontal?.gameObject);
            UIHandler.Instance.RegisterOrientationObjects(boostButtonVertical?.gameObject, boostButtonHorizontal?.gameObject);
        }

        // 元の色を保存
        if (leftHandParticle != null)  leftOriginalColor  = leftHandParticle.main.startColor.color;
        if (rightHandParticle != null) rightOriginalColor = rightHandParticle.main.startColor.color;

        // 初期は白
        SetTrailColor(Color.white, Color.white);
        UpdateBoostUI();
    }

    void Update()
    {
        // “入力からのBoost要求” or “UIボタンでの手動トグル” のどちらかが真ならBoost要求ON
        bool requestBoost = (mobileInput != null && mobileInput.boost) || forceToggleFromUIButton;

        // 要求があって、残量があるならBoost ON、無いならOFF
        if (requestBoost && currentBoost > 0f)
        {
            if (!isBoosting)
            {
                isBoosting = true;
                OnBoostVisualsChanged(true);
            }

            // 消費
            currentBoost -= boostConsumptionRate * Time.deltaTime;
            currentBoost = Mathf.Clamp(currentBoost, 0f, maxBoost);

            // 使い切ったら即OFF
            if (currentBoost <= 0f)
            {
                isBoosting = false;
                OnBoostVisualsChanged(false);
            }
        }
        else
        {
            if (isBoosting)
            {
                isBoosting = false;
                OnBoostVisualsChanged(false);
            }

            // 回復
            if (currentBoost < maxBoost)
            {
                currentBoost += boostRechargeRate * Time.deltaTime;
                currentBoost = Mathf.Clamp(currentBoost, 0f, maxBoost);
            }
        }

        UpdateBoostUI();
    }

    // --- UI/演出まわり ---

    private void ToggleBoostManual()
    {
        // モバイルの “タップBoost” と併用する想定なので、
        // UIボタンは単純トグル動作にしておく
        forceToggleFromUIButton = !forceToggleFromUIButton;
    }

    private void OnBoostVisualsChanged(bool enabled)
    {
        // ボタン色変更（任意）
        UpdateButtonColor(enabled ? Color.yellow : Color.white);

        // パーティクル色
        SetParticleColor(enabled ? Color.yellow : leftOriginalColor,
                         enabled ? Color.yellow : rightOriginalColor);

        // トレイル色
        SetTrailColor(enabled ? Color.yellow : Color.white,
                      enabled ? Color.yellow : Color.white);
    }

    private void UpdateBoostUI()
    {
        float fill = (maxBoost <= 0f) ? 0f : currentBoost / maxBoost;
        if (boostBarVertical   != null) boostBarVertical.value   = fill;
        if (boostBarHorizontal != null) boostBarHorizontal.value = fill;
    }

    private void UpdateButtonColor(Color c)
    {
        if (boostButtonVertical   != null) boostButtonVertical.GetComponent<Image>().color   = c;
        if (boostButtonHorizontal != null) boostButtonHorizontal.GetComponent<Image>().color = c;
    }

    private void SetParticleColor(Color leftColor, Color rightColor)
    {
        if (leftHandParticle != null)
        {
            var m = leftHandParticle.main; m.startColor = leftColor;
        }
        if (rightHandParticle != null)
        {
            var m = rightHandParticle.main; m.startColor = rightColor;
        }
    }

    private void SetTrailColor(Color leftColor, Color rightColor)
    {
        if (leftTrail  != null) { leftTrail.startColor  = leftColor;  leftTrail.endColor  = leftColor; }
        if (rightTrail != null) { rightTrail.startColor = rightColor; rightTrail.endColor = rightColor; }
    }

    // 外部からの回復API（アイテムなど）
    public void RecoverBoost(float amount)
    {
        currentBoost = Mathf.Clamp(currentBoost + Mathf.Max(0f, amount), 0f, maxBoost);
    }
}
