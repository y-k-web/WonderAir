using UnityEngine;
using UnityEngine.InputSystem;

public class MobileInput : MonoBehaviour
{
    public Vector2 drag;
    public bool isForward;
    public bool boost;

    // PlayerInput が自動で呼ぶメソッド
    public void OnPitchRollYaw(InputAction.CallbackContext ctx)
        => drag = ctx.ReadValue<Vector2>();

    public void OnMoveForward(InputAction.CallbackContext ctx)
        => isForward = ctx.ReadValueAsButton();

    public void OnBoost(InputAction.CallbackContext ctx)
    {
        if (ctx.performed)
            boost = true;
        if (ctx.canceled)
            boost = false;
    }
}
