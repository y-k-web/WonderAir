using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [Header("Input Actions (.inputactions をアサイン)")]
    public InputActionReference forwardAction; // Holdで前進
    public InputActionReference dragAction;    // Vector2: マウス/タッチのDelta

    [Header("Movement")]
    public float normalSpeed = 6f;
    public float yawFactor   = 90f;
    public float pitchFactor = 90f;

    [Header("Gentle Fall (前進停止後の自然落下)")]
    public float fallDelaySeconds = 0.5f;   // 何秒後に落下開始
    public float fallAccel        = 2.0f;   // 落下加速度(擬似)
    public float maxFallSpeed     = 3.0f;   // 最大落下速度(絶対値)

    [Header("Refs")]
    public BoostController boost;   // ← BoostController をドラッグで割り当て
    public Animator animator;       // 任意

    // runtime state
    private bool forwardHeld;
    private Vector2 drag;
    private float timeSinceForwardReleased = 0f;
    private float verticalVel = 0f; // 自然落下用（Rigidbody非使用の簡易実装）

    void OnEnable()
    {
        Enable(forwardAction, OnForward);
        Enable(dragAction,    OnDrag);
        Debug.Log("[PlayerController] Input ENABLED");
    }
    void OnDisable()
    {
        Disable(forwardAction, OnForward);
        Disable(dragAction,    OnDrag);
        Debug.Log("[PlayerController] Input DISABLED");
    }

    void Update()
    {
        // 速度決定：BoostController の倍率を採用
        float speedMul = (boost != null) ? boost.CurrentSpeedMultiplier : 1f;
        float speed    = normalSpeed * speedMul;

        // アニメーター
        if (animator)
        {
            animator.SetBool("IsFlying",   forwardHeld);
            if (boost) animator.SetBool("IsBoosting", boost.IsBoosting);
        }

        // 前進
        if (forwardHeld)
        {
            transform.position += transform.forward * speed * Time.deltaTime;

            // 前進中は落下リセット
            timeSinceForwardReleased = 0f;
            verticalVel = 0f;
        }
        else
        {
            // 停止してからの経過
            timeSinceForwardReleased += Time.deltaTime;

            // 遅延後にゆっくり自然落下（Rigidbodyなし版）
            if (timeSinceForwardReleased >= fallDelaySeconds)
            {
                // v = v + a*dt（下向きを負方向とする）
                verticalVel = Mathf.MoveTowards(
                    verticalVel,
                    -maxFallSpeed,
                    fallAccel * Time.deltaTime
                );
                transform.position += Vector3.up * verticalVel * Time.deltaTime;
            }
        }

        // ドラッグで機体を向ける
        var d = drag * Time.deltaTime; // 秒間回転量に
        transform.Rotate(-d.y * pitchFactor, d.x * yawFactor, 0f, Space.Self);

        // デバッグ（必要なら）
        // Debug.Log($"FWD:{forwardHeld} BOOST:{(boost?boost.IsBoosting:false)} MUL:{speedMul:F2} Vv:{verticalVel:F2}");
    }

    // ---- callbacks ----
    private void OnForward(InputAction.CallbackContext ctx)
    {
        forwardHeld = ctx.ReadValueAsButton();
    }
    private void OnDrag(InputAction.CallbackContext ctx)
    {
        if (ctx.performed || ctx.canceled)
            drag = ctx.ReadValue<Vector2>();
    }

    // ---- util ----
    private static void Enable(InputActionReference r, System.Action<InputAction.CallbackContext> cb)
    {
        if (!r) { Debug.LogWarning("InputActionReference not set"); return; }
        r.action.Enable();
        r.action.started   += cb;
        r.action.performed += cb;
        r.action.canceled  += cb;
    }
    private static void Disable(InputActionReference r, System.Action<InputAction.CallbackContext> cb)
    {
        if (!r) return;
        r.action.started   -= cb;
        r.action.performed -= cb;
        r.action.canceled  -= cb;
        r.action.Disable();
    }
}
