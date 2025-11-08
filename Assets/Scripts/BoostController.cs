using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class BoostController : MonoBehaviour
{
    [Header("UI")]
    [SerializeField] private Slider[] boostBars;

    [Header("UI Follow Settings")]
    [SerializeField] private Vector2 screenOffset = new Vector2(120f, 40f);

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
    private Camera cachedCamera;

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

        ConfigureBoostUI();
        UpdateBoostUI();
        SetBoostUIVisibility(ShouldShowBoostUI());
        UpdateBoostUIPosition();
    }

    private void OnDisable()
    {
        if (boostAction != null)
        {
            boostAction.action.performed -= OnBoostPerformed;
            boostAction.action.Disable();
        }

        SetBoostUIVisibility(false);
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
        SetBoostUIVisibility(ShouldShowBoostUI());
        UpdateBoostUIPosition();
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
        SetBoostUIVisibility(ShouldShowBoostUI());
    }

    public void DisableBoost()
    {
        isBoosting = false;
        SetFXColor(leftOriginalColor, rightOriginalColor);
        SetBoostUIVisibility(ShouldShowBoostUI());
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
        SetBoostUIVisibility(ShouldShowBoostUI());
    }

    private void UpdateBoostUI()
    {
        float v = (maxBoost <= 0f) ? 0f : currentBoost / maxBoost;
        foreach (Slider slider in EnumerateBoostBars())
        {
            slider.value = v;
        }
    }

    private void ConfigureBoostUI()
    {
        foreach (Slider slider in EnumerateBoostBars())
        {
            ConfigureBoostSlider(slider);
        }
    }

    private void ConfigureBoostSlider(Slider slider)
    {
        if (!slider) return;

        slider.direction = Slider.Direction.BottomToTop;

        RectTransform rect = slider.GetComponent<RectTransform>();
        if (rect)
        {
            rect.anchorMin = rect.anchorMax = new Vector2(0.5f, 0.5f);
            rect.sizeDelta = new Vector2(18f, 140f);
        }

        RectTransform fillArea = slider.transform.Find("Fill Area") as RectTransform;
        if (fillArea)
        {
            fillArea.anchorMin = new Vector2(0.25f, 0f);
            fillArea.anchorMax = new Vector2(0.75f, 1f);
            fillArea.sizeDelta = Vector2.zero;
        }

        RectTransform background = slider.transform.Find("Background") as RectTransform;
        if (background)
        {
            background.anchorMin = new Vector2(0.25f, 0f);
            background.anchorMax = new Vector2(0.75f, 1f);
            background.sizeDelta = Vector2.zero;
        }

        if (slider.fillRect)
        {
            RectTransform fill = slider.fillRect;
            fill.anchorMin = new Vector2(0f, 0f);
            fill.anchorMax = new Vector2(1f, 1f);
            fill.pivot = new Vector2(0.5f, 0f);
        }

        RectTransform label = slider.transform.Find("Text (TMP)") as RectTransform;
        if (label)
        {
            label.anchorMin = label.anchorMax = new Vector2(1f, 0.5f);
            label.pivot = new Vector2(0f, 0.5f);
            label.anchoredPosition = new Vector2(24f, 0f);
            label.sizeDelta = new Vector2(70f, 24f);

            TextMeshProUGUI labelText = label.GetComponent<TextMeshProUGUI>();
            if (labelText)
            {
                labelText.alignment = TextAlignmentOptions.Left;
                labelText.enableWordWrapping = false;
            }
        }
    }

    private void UpdateBoostUIPosition()
    {
        foreach (Slider slider in EnumerateBoostBars())
        {
            UpdateSliderPosition(slider, screenOffset);
        }
    }

    private void UpdateSliderPosition(Slider slider, Vector2 screenOffset)
    {
        if (!slider)
        {
            return;
        }

        RectTransform sliderRect = slider.GetComponent<RectTransform>();
        if (!sliderRect)
        {
            return;
        }

        Canvas canvas = slider.GetComponentInParent<Canvas>();
        if (!canvas)
        {
            return;
        }

        RectTransform canvasRect = canvas.GetComponent<RectTransform>();
        if (!canvasRect)
        {
            return;
        }

        Camera camera = GetCameraForCanvas(canvas);
        Vector3 worldPosition = transform.position;
        Vector2 screenPoint = RectTransformUtility.WorldToScreenPoint(camera, worldPosition);
        Vector2 targetScreenPoint = screenPoint + screenOffset;

        if (RectTransformUtility.ScreenPointToLocalPointInRectangle(canvasRect, targetScreenPoint, camera, out Vector2 localPoint))
        {
            sliderRect.anchoredPosition = localPoint;
        }
    }

    private Camera GetCameraForCanvas(Canvas canvas)
    {
        if (canvas.renderMode == RenderMode.ScreenSpaceOverlay)
        {
            return null;
        }

        if (canvas.worldCamera)
        {
            return canvas.worldCamera;
        }

        if (!cachedCamera)
        {
            cachedCamera = Camera.main;
        }

        return cachedCamera;
    }

    private bool ShouldShowBoostUI()
    {
        return isBoosting;
    }

    private void SetBoostUIVisibility(bool visible)
    {
        foreach (Slider slider in EnumerateBoostBars())
        {
            GameObject sliderGO = slider.gameObject;
            if (sliderGO.activeSelf != visible)
            {
                sliderGO.SetActive(visible);
            }
        }
    }

    private IEnumerable<Slider> EnumerateBoostBars()
    {
        if (boostBars == null)
        {
            yield break;
        }

        foreach (Slider slider in boostBars)
        {
            if (slider)
            {
                yield return slider;
            }
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
