using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [Header("Input (assign in Inspector)")]
    public InputActionReference moveForward;   // Button
    public InputActionReference drag;          // Vector2 (Pointer/delta)
    public InputActionReference boost;         // Button (Tap)

    [Header("Move Params")]
    public float normalSpeed = 6f;
    public float boostSpeed = 12f;
    public float yawFactor = 120f;   // 水平方向
    public float pitchFactor = 120f; // 垂直方向

    float _speed;

    void OnEnable()
    {
        moveForward?.action.Enable();
        drag?.action.Enable();
        boost?.action.Enable();
        _speed = normalSpeed;
    }

    void OnDisable()
    {
        moveForward?.action.Disable();
        drag?.action.Disable();
        boost?.action.Disable();
    }

    void Update()
    {
        // Boost（タップで一時的に上げたいなら WasPerformedThisFrame を使う）
        bool boosting = boost != null && boost.action.IsPressed();
        _speed = boosting ? boostSpeed : normalSpeed;

        // 前進：指を置いている/ボタン押下中に進む
        bool forward = moveForward != null && moveForward.action.IsPressed();
        if (forward)
            transform.position += transform.forward * _speed * Time.deltaTime;

        // ドラッグで機体の向きを変える（X=Yaw, Y=Pitch）
        if (drag != null)
        {
            Vector2 d = drag.action.ReadValue<Vector2>();
            // フレーム依存の Pointer delta なので、スケールはお好みで
            float yaw   = d.x * yawFactor   * Time.deltaTime;
            float pitch = -d.y * pitchFactor * Time.deltaTime;
            transform.Rotate(pitch, yaw, 0f, Space.Self);
        }
    }
}
