using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class BoostController : MonoBehaviour
{
    [Header("UI")]
    [SerializeField] private GameObject boostGaugeRoot;
    [SerializeField] private Slider boostBar;

    [Header("Boost Settings")]
    [SerializeField] private float maxBoost = 100f;
    [SerializeField] private float boostConsumptionRate = 20f; // /sec
    [SerializeField] private float boostRechargeRate   = 10f;  // /sec
    [SerializeField] private float boostSpeedMultiplier = 2.0f;

    [Header("Input (New Input System)")]
    // Input Action Asset の "Boost"（Button）に割り当てた InputActionReference を入れる
    [SerializeField] private InputActionReference boostAction; // Tapでトグル

    // 参照系（任意）
    [Header("Optional FX")]
    [SerializeField] private ParticleSystem leftHandParticle;
    [SerializeField] private ParticleSystem rightHandParticle;
    [SerializeField] private TrailRenderer leftTrail;
    [SerializeField] private TrailRenderer rightTrail;

    // 状態
    private bool isBoosting = false;
    private float currentBoost;
    private Color leftOriginalColor = Color.white;
    private Color rightOriginalColor = Color.white;

    // 他スクリプト用読み取り
    public bool IsBoosting => isBoosting;
    public float CurrentSpeedMultiplier => isBoosting ? boostSpeedMultiplier : 1f;

    private void OnEnable()
    {
        currentBoost = Mathf.Clamp(currentBoost == 0 ? maxBoost : currentBoost, 0, maxBoost);

        if (boostAction != null)
        {
            boostAction.action.Enable();
            // 「タップでトグル」…ボタンが押されたフレームで切替
            boostAction.action.performed += OnBoostPerformed;
        }

        // 元色を保存
        if (leftHandParticle)  leftOriginalColor  = leftHandParticle.main.startColor.color;
        if (rightHandParticle) rightOriginalColor = rightHandParticle.main.startColor.color;

        UpdateBoostUI();
        SetBoostGaugeVisible(false);
    }

    private void OnDisable()
    {
        if (boostAction != null)
        {
            boostAction.action.performed -= OnBoostPerformed;
            boostAction.action.Disable();
        }

        SetBoostGaugeVisible(false);
    }

    private void Update()
    {
        if (isBoosting && currentBoost > 0f)
        {
            currentBoost -= boostConsumptionRate * Time.deltaTime;
            if (currentBoost <= 0f)
            {
                currentBoost = 0f;
                DisableBoost(); // ゼロで強制OFF
            }
        }
        else
        {
            // 非ブースト時はリチャージ
            if (currentBoost < maxBoost)
            {
                currentBoost += boostRechargeRate * Time.deltaTime;
                if (currentBoost > maxBoost) currentBoost = maxBoost;
            }
        }

        UpdateBoostUI();
    }

    private void OnBoostPerformed(InputAction.CallbackContext ctx)
    {
        // タップ/クリックでトグル
        if (isBoosting) DisableBoost();
        else if (currentBoost > 0f) EnableBoost();
    }

    public void EnableBoost()
    {
        if (currentBoost <= 0f) return;
        isBoosting = true;
        SetFXColor(Color.yellow, Color.yellow);
        SetBoostGaugeVisible(true);
    }

    public void DisableBoost()
    {
        isBoosting = false;
        SetFXColor(leftOriginalColor, rightOriginalColor);
        SetBoostGaugeVisible(false);
    }

    public void ToggleBoost()  // UIボタンからも呼べるように
    {
        if (isBoosting) DisableBoost();
        else if (currentBoost > 0f) EnableBoost();
    }

    public void RecoverBoost(float amount)  // ItemController から呼ぶ用
    {
        currentBoost = Mathf.Clamp(currentBoost + Mathf.Abs(amount), 0f, maxBoost);
        UpdateBoostUI();
    }

    private void UpdateBoostUI()
    {
        float v = (maxBoost <= 0f) ? 0f : currentBoost / maxBoost;
        if (boostBar) boostBar.value = v;
    }

    private void SetBoostGaugeVisible(bool visible)
    {
        if (!boostGaugeRoot) return;

        if (boostGaugeRoot.activeSelf != visible)
        {
            boostGaugeRoot.SetActive(visible);
        }
    }

    private void SetFXColor(Color leftColor, Color rightColor)
    {
        if (leftHandParticle)
        {
            var m = leftHandParticle.main;
            m.startColor = leftColor;
        }
        if (rightHandParticle)
        {
            var m = rightHandParticle.main;
            m.startColor = rightColor;
        }
        if (leftTrail)  { leftTrail.startColor  = leftColor; }
        if (rightTrail) { rightTrail.startColor = rightColor; }
    }
}
