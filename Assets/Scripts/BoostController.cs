using UnityEngine;
using UnityEngine.UI;

public class BoostController : MonoBehaviour
{
    public Slider boostBar; // ゲージのUI要素（Slider）
    public Slider boostBar2; // ゲージのUI要素（Slider）
    public float maxBoost = 100f; // ブーストゲージの最大値
    public float boostConsumptionRate = 20f; // ブーストの消費速度
    public float boostRechargeRate = 10f; // ブーストの回復速度

    private float currentBoost; // 現在のブースト量

    void Awake()
    {
        currentBoost = maxBoost;
        UpdateBoostUI();
    }

    void Update()
    {
        // ブーストゲージの回復
        if (currentBoost < maxBoost)
        {
            currentBoost += boostRechargeRate * Time.deltaTime;
            currentBoost = Mathf.Clamp(currentBoost, 0, maxBoost);
            UpdateBoostUI();
        }

    }

    public void RecoverBoost(float amount)
    {
        currentBoost += amount;
        currentBoost = Mathf.Clamp(currentBoost, 0, maxBoost);
        UpdateBoostUI();
    }

    public void UseBoost()
    {
        if (currentBoost > 0)
        {
            currentBoost -= boostConsumptionRate * Time.deltaTime;
            UpdateBoostUI();
        }
    }

    public bool IsBoostEmpty()
    {
        return currentBoost <= 0;
    }

    void UpdateBoostUI()
    {
        // ゲージUIの更新
        float fillAmount = currentBoost / maxBoost;
        boostBar.value = fillAmount;
        boostBar2.value = fillAmount;
    }
}
