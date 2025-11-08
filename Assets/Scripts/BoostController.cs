using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using WonderAir.Drone;

public class BoostController : MonoBehaviour
{
    [Header("Gauge")]
    public Slider boostBarVertical;
    public Slider boostBarHorizontal;

    [Header("Boost Settings")]
    public float maxBoost = 100f;
    public float boostConsumptionRate = 20f;
    public float boostRechargeRate = 10f;
    public float boostSpeedMultiplier = 2.0f;

    [Header("Input Actions")]
    [SerializeField] private InputActionAsset inputActions;
    [SerializeField] private string boostActionName = "Player/Boost";

    [Header("VFX")]
    public ParticleSystem leftHandParticle;
    public ParticleSystem rightHandParticle;
    public TrailRenderer leftTrail;
    public TrailRenderer rightTrail;

    private bool isBoosting;
    private float currentBoost;

    private DroneController droneController;
    private float originalMaxSpeed;
    private Color leftOriginalColor;
    private Color rightOriginalColor;

    private InputAction boostAction;

    public bool IsBoosting => isBoosting;

    private void Awake()
    {
        currentBoost = maxBoost;
        droneController = GetComponent<DroneController>();

        if (droneController == null)
        {
            Debug.LogError("DroneController が見つかりません。同じオブジェクトにアタッチしてください。");
            enabled = false;
            return;
        }

        originalMaxSpeed = droneController.maxSpeed;

        if (UIHandler.Instance != null)
        {
            UIHandler.Instance.RegisterOrientationObjects(boostBarVertical?.gameObject, boostBarHorizontal?.gameObject);
        }

        CacheOriginalColors();
        SetTrailColor(Color.white, Color.white);
        UpdateBoostUI();
    }

    private void OnEnable()
    {
        ResolveBoostAction();
        if (boostAction != null)
        {
            boostAction.performed += OnBoostPerformed;
            boostAction.Enable();
        }
    }

    private void OnDisable()
    {
        if (boostAction != null)
        {
            boostAction.performed -= OnBoostPerformed;
            boostAction.Disable();
        }
    }

    private void Update()
    {
        if (droneController == null)
        {
            return;
        }

        if (isBoosting && currentBoost > 0f)
        {
            currentBoost -= boostConsumptionRate * Time.deltaTime;
            currentBoost = Mathf.Clamp(currentBoost, 0f, maxBoost);

            droneController.maxSpeed = originalMaxSpeed * boostSpeedMultiplier;

            if (currentBoost <= 0f)
            {
                DisableBoost();
            }
        }
        else
        {
            droneController.maxSpeed = originalMaxSpeed;

            if (currentBoost < maxBoost)
            {
                currentBoost += boostRechargeRate * Time.deltaTime;
                currentBoost = Mathf.Clamp(currentBoost, 0f, maxBoost);
            }
        }

        UpdateBoostUI();
    }

    private void OnBoostPerformed(InputAction.CallbackContext context)
    {
        bool triggeredByKeyboard = context.control?.device is Keyboard;

        if (!triggeredByKeyboard && !CanStartBoost())
        {
            return;
        }

        ToggleBoost();
    }

    private bool CanStartBoost()
    {
        if (droneController == null)
        {
            return false;
        }

        var handler = droneController.InputHandler;
        if (handler != null && handler.Pitch > 0.1f)
        {
            return true;
        }

        Rigidbody body = droneController.Rb;
        if (body == null)
        {
            return false;
        }

        float forwardSpeed = Vector3.Dot(body.velocity, droneController.transform.forward);
        return forwardSpeed > 0.5f;
    }

    private void ToggleBoost()
    {
        if (!isBoosting && currentBoost > 0f)
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
        SetParticleColor(Color.yellow, Color.yellow);
        SetTrailColor(Color.yellow, Color.yellow);
        UpdateBoostUI();
    }

    private void DisableBoost()
    {
        isBoosting = false;
        SetParticleColor(leftOriginalColor, rightOriginalColor);
        SetTrailColor(Color.white, Color.white);
        UpdateBoostUI();
    }

    private void UpdateBoostUI()
    {
        float fillAmount = maxBoost > 0f ? currentBoost / maxBoost : 0f;

        if (boostBarVertical != null)
        {
            boostBarVertical.value = fillAmount;
        }

        if (boostBarHorizontal != null)
        {
            boostBarHorizontal.value = fillAmount;
        }

        UpdateGaugeVisibility();
    }

    private void UpdateGaugeVisibility()
    {
        bool shouldShow = isBoosting || currentBoost < maxBoost;

        if (boostBarVertical != null)
        {
            boostBarVertical.gameObject.SetActive(shouldShow);
        }

        if (boostBarHorizontal != null)
        {
            boostBarHorizontal.gameObject.SetActive(shouldShow);
        }
    }

    private void CacheOriginalColors()
    {
        if (leftHandParticle != null)
        {
            leftOriginalColor = leftHandParticle.main.startColor.color;
        }

        if (rightHandParticle != null)
        {
            rightOriginalColor = rightHandParticle.main.startColor.color;
        }
    }

    private void SetParticleColor(Color leftColor, Color rightColor)
    {
        if (leftHandParticle != null)
        {
            var main = leftHandParticle.main;
            main.startColor = leftColor;
        }

        if (rightHandParticle != null)
        {
            var main = rightHandParticle.main;
            main.startColor = rightColor;
        }
    }

    private void SetTrailColor(Color leftColor, Color rightColor)
    {
        if (leftTrail != null)
        {
            leftTrail.startColor = leftColor;
        }

        if (rightTrail != null)
        {
            rightTrail.startColor = rightColor;
        }
    }

    public void RecoverBoost(float amount)
    {
        currentBoost += amount;
        currentBoost = Mathf.Clamp(currentBoost, 0, maxBoost);
        UpdateBoostUI();
    }

    private void ResolveBoostAction()
    {
        if (inputActions == null)
        {
            boostAction = null;
            return;
        }

        try
        {
            boostAction = inputActions.FindAction(boostActionName, true);
        }
        catch (System.Exception)
        {
            Debug.LogWarning($"Boost action '{boostActionName}' not found on asset '{inputActions.name}'.");
            boostAction = null;
        }
    }
}
