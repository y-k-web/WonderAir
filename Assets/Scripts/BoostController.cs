using UnityEngine;
using UnityEngine.UI;

public class BoostController : MonoBehaviour
{
    public Slider boostBarVertical;   // 縦画面用のブーストゲージ
    public Slider boostBarHorizontal; // 横画面用のブーストゲージ
    public float maxBoost = 100f;     // ブーストゲージの最大値
    public float boostConsumptionRate = 20f; // ブーストの消費速度
    public float boostRechargeRate = 10f;    // ブーストの回復速度
    public float boostSpeedMultiplier = 2.0f; // ブースト時の速度倍率

    public Button boostButtonVertical;   // 縦画面用のブーストボタン
    public Button boostButtonHorizontal; // 横画面用のブーストボタン

    private bool isBoosting = false;  // ブーストが有効かどうか
    private float currentBoost;       // 現在のブースト量

    private RageRunGames.EasyFlyingSystem.DroneController droneController; // ドローン制御用の参照
    private float originalMaxSpeed;   // 初期の最大速度を保存

    void Awake()
    {
        currentBoost = maxBoost;
        droneController = GetComponent<RageRunGames.EasyFlyingSystem.DroneController>();

        if (droneController == null)
        {
            Debug.LogError("DroneController が見つかりません。同じオブジェクトにアタッチしてください。");
        }

        originalMaxSpeed = droneController.maxSpeed; // DroneController の初期速度を保存

        // ボタンのクリックイベントを設定
        if (boostButtonVertical != null)
        {
            boostButtonVertical.onClick.AddListener(ToggleBoost);
        }
        if (boostButtonHorizontal != null)
        {
            boostButtonHorizontal.onClick.AddListener(ToggleBoost);
        }

        UpdateBoostUI();

        if (UIHandler.Instance != null)
        {
            UIHandler.Instance.RegisterOrientationObjects(boostBarVertical?.gameObject, boostBarHorizontal?.gameObject);
            UIHandler.Instance.RegisterOrientationObjects(boostButtonVertical?.gameObject, boostButtonHorizontal?.gameObject);
        }
    }

    void Update()
    {
        if (isBoosting && currentBoost > 0)
        {
            // ブースト中にゲージを消費
            currentBoost -= boostConsumptionRate * Time.deltaTime;
            currentBoost = Mathf.Clamp(currentBoost, 0, maxBoost);

            // ブースト中の速度を設定
            droneController.maxSpeed = originalMaxSpeed * boostSpeedMultiplier;

            // ブーストがゼロになったら自動解除
            if (currentBoost <= 0)
            {
                DisableBoost();
            }
        }
        else
        {
            // ブーストが解除されたら元の速度に戻す
            droneController.maxSpeed = originalMaxSpeed;

            // ブーストゲージの回復
            if (currentBoost < maxBoost)
            {
                currentBoost += boostRechargeRate * Time.deltaTime;
                currentBoost = Mathf.Clamp(currentBoost, 0, maxBoost);
            }
        }

        UpdateBoostUI();
    }

    private void ToggleBoost()
    {
        if (!isBoosting && currentBoost > 0)
        {
            EnableBoost();
        }
        else
        {
            DisableBoost();
        }
    }

    private void EnableBoost()
    {
        isBoosting = true;
        UpdateButtonColor();
    }

    private void DisableBoost()
    {
        isBoosting = false;
        UpdateButtonColor();
    }

    private void UpdateBoostUI()
    {
        float fillAmount = currentBoost / maxBoost;
        if (boostBarVertical != null)
        {
            boostBarVertical.value = fillAmount;
        }
        if (boostBarHorizontal != null)
        {
            boostBarHorizontal.value = fillAmount;
        }
    }

    private void UpdateButtonColor()
    {
        Color targetColor = isBoosting ? Color.yellow : Color.white;

        if (boostButtonVertical != null)
        {
            boostButtonVertical.GetComponent<Image>().color = targetColor;
        }
        if (boostButtonHorizontal != null)
        {
            boostButtonHorizontal.GetComponent<Image>().color = targetColor;
        }
    }

    public void RecoverBoost(float amount)
    {
        currentBoost += amount;
        currentBoost = Mathf.Clamp(currentBoost, 0, maxBoost);
    }
}
