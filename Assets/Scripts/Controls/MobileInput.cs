using UnityEngine;
using UnityEngine.InputSystem;
using RageRunGames.EasyFlyingSystem;

public class MobileInput : MonoBehaviour
{
    public Vector2 drag;
    public bool isForward;
    public bool boost;

    [SerializeField] private MobileController mobileController;
    [SerializeField, Range(0.001f, 0.1f)] private float pointerSensitivity = 0.01f;

    private float horizontalValue;

    // PlayerInput が自動で呼ぶメソッド
    public void OnPitchRollYaw(InputAction.CallbackContext ctx)
    {
        drag = ctx.ReadValue<Vector2>();
        horizontalValue = Mathf.Clamp(horizontalValue + drag.x * pointerSensitivity, -1f, 1f);
        UpdateControllerInput();
    }

    public void OnMoveForward(InputAction.CallbackContext ctx)
    {
        isForward = ctx.ReadValueAsButton();
        UpdateControllerInput();
    }

    public void OnBoost(InputAction.CallbackContext ctx)
    {
        if (ctx.performed)
            boost = true;
        if (ctx.canceled)
            boost = false;
    }

    private void Awake()
    {
        if (mobileController == null)
        {
            mobileController = FindFirstObjectByType<MobileController>();
        }

        if (mobileController != null)
        {
            mobileController.UseUnityInputFallback = false;
            UpdateControllerInput();
        }
    }

    private void UpdateControllerInput()
    {
        if (mobileController == null)
        {
            return;
        }

        float forwardValue = isForward ? 1f : 0f;
        Vector2 baseInput = new Vector2(horizontalValue, forwardValue);
        mobileController.SetBaseInput(baseInput);
    }
}
