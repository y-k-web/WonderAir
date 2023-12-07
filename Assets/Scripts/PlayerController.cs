using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.EnhancedTouch;
using Touch = UnityEngine.InputSystem.EnhancedTouch.Touch;
public class PlayerController : MonoBehaviour
{
    public bool CanMove = true;
    public bool CanMoveForward = true;
    public bool CanMoveBack = true;
    public bool CanMoveLeft = true;
    public bool CanMoveRight = true;
    public bool CanMoveUp = true;
    public bool CanMoveDown = true;
    public bool CanRotateYaw = true;
    public bool CanRotatePitch = true;
    public bool CanRotateRoll = true;

    public float MovementSpeed = 30f;
    public float RotationSpeed = 0.01f;
    public float zRotationReturnSpeed = 1.0f;

    private bool canTranslate;
    private bool canRotate;

    private float originalMovementSpeed;
    private bool isSpeedBoostActive = false;

    private BoostController boostController;
    private bool isBoosting = false;
    public ParticleSystem playerParticle1;
    public ParticleSystem playerParticle2;
    public Color defaultParticleColor = Color.white;
    public Color boostParticleColor = Color.yellow;

    public InputAction dragAction;
    public InputAction boostAction;
    private Vector2 currentDrag;
    private bool isGameOver = false;


    private float currentPitchAngle = 0f;
    private float currentYawAngle = 0f;

    void Awake()
    {
        dragAction = new InputAction(binding: "<Touchscreen>/primaryTouch/delta", type: InputActionType.Value);
        boostAction = new InputAction(binding: "<Touchscreen>/primaryTouch/tap", type: InputActionType.Button);


        dragAction.performed += OnDragPerformed;
        dragAction.canceled += OnDragCanceled;

        boostAction.performed += OnBoostPerformed;
    }

    void OnEnable()
    {
        dragAction.Enable();
        boostAction.Enable();
    }

    void OnDisable()
    {
        dragAction.Disable();
        boostAction.Disable();
    }

    void Start()
    {
        canTranslate = CanRotateYaw || CanRotatePitch || CanRotateRoll;
        canRotate = CanMoveForward || CanMoveBack || CanMoveRight || CanMoveLeft || CanMoveUp || CanMoveDown;

        originalMovementSpeed = MovementSpeed;

        boostController = GetComponent<BoostController>();

        if (playerParticle1 == null)
        {
            playerParticle1 = GetComponent<ParticleSystem>();
        }

        if (playerParticle2 == null)
        {
            playerParticle2 = GetComponent<ParticleSystem>();

        }
        SetParticleColor(playerParticle1, defaultParticleColor);
        SetParticleColor(playerParticle2, defaultParticleColor);
    }
    void OnDragPerformed(InputAction.CallbackContext context)
    {
        currentDrag = Vector2.ClampMagnitude(context.ReadValue<Vector2>(), 0.08f);

        // Yaw回転の計算（左右ドラッグでの旋回）
        float desiredYawChange = currentDrag.x * RotationSpeed;
        transform.Rotate(Vector3.up * desiredYawChange);
        currentYawAngle += desiredYawChange;

        // Pitch回転の計算（上下ドラッグでの首を上下に振る）
        // 注意：ドラッグの上下方向とキャラクターの動きが逆になるように-（マイナス）を使用
        float desiredPitchChange = -currentDrag.y * RotationSpeed;
        transform.Rotate(Vector3.right * desiredPitchChange);
        currentPitchAngle += desiredPitchChange;
    }










    void OnDragCanceled(InputAction.CallbackContext context)
    {
        currentDrag = Vector2.zero;
    }
    void OnBoostPerformed(InputAction.CallbackContext context)
    {
        if (!isBoosting && !boostController.IsBoostEmpty())
        {
            isBoosting = true;
            originalMovementSpeed = MovementSpeed;
            MovementSpeed *= 2.0f;
            SetParticleColor(playerParticle1, boostParticleColor);
            SetParticleColor(playerParticle2, boostParticleColor);

        }
        else if (isBoosting)
        {
            isBoosting = false;
            MovementSpeed = originalMovementSpeed;
            SetParticleColor(playerParticle1, defaultParticleColor);
            SetParticleColor(playerParticle2, defaultParticleColor);
            boostController.UseBoost();
        }
    }

    void Update()
    {
        Rigidbody rb = GetComponent<Rigidbody>();
        rb.interpolation = RigidbodyInterpolation.Interpolate;

        if(CanMove && !isGameOver){
        // カメラの方向に基づく自動移動
        Vector3 forwardMovement = Camera.main.transform.forward * MovementSpeed * Time.deltaTime;
        rb.MovePosition(rb.position + forwardMovement);

        // Z軸のリセット (必要であれば)
        ResetZRotation();


        if (isBoosting)
        {
            boostController.UseBoost();

            // もしブーストゲージが空だったら、ブーストを停止する
            if (boostController.IsBoostEmpty())
            {
                isBoosting = false;
                MovementSpeed = originalMovementSpeed;
                SetParticleColor(playerParticle1, defaultParticleColor);
                SetParticleColor(playerParticle2, defaultParticleColor);
            }
        }
        }
    }

    void SetParticleColor(ParticleSystem particleSystem, Color color)
    {
        var mainModule = particleSystem.main;
        mainModule.startColor = color;
    }

    void UpdatePosition()
    {
        Rigidbody rb = GetComponent<Rigidbody>();
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Terrain"))
        {
            Vector3 clampedPosition = transform.position;
            clampedPosition.x = Mathf.Clamp(clampedPosition.x, other.bounds.min.x, other.bounds.max.x);
            clampedPosition.y = Mathf.Clamp(clampedPosition.y, other.bounds.min.y, other.bounds.max.y);
            clampedPosition.z = Mathf.Clamp(clampedPosition.z, other.bounds.min.z, other.bounds.max.z);

            transform.position = clampedPosition;
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("boundary"))
        {
            Vector3 clampedPosition = transform.position;
            clampedPosition.x = Mathf.Clamp(clampedPosition.x, other.bounds.min.x, other.bounds.max.x);
            clampedPosition.y = Mathf.Clamp(clampedPosition.y, other.bounds.min.y, other.bounds.max.y);
            clampedPosition.z = Mathf.Clamp(clampedPosition.z, other.bounds.min.z, other.bounds.max.z);

            transform.position = clampedPosition;
        }
        else if (other.CompareTag("Title"))
        {
            SceneManager.LoadScene("FreeAir");
        }
    }

    void ResetZRotation()
    {
        float currentZRotation = transform.eulerAngles.z;
        if (Mathf.Abs(currentZRotation) > 0.001f)
        {
            float newZRotation = Mathf.LerpAngle(currentZRotation, 0, zRotationReturnSpeed * Time.deltaTime);
            Vector3 currentRotation = transform.eulerAngles;
            currentRotation.z = newZRotation;
            transform.eulerAngles = currentRotation;
        }
    }

    public void SetCanMove(bool canMove)
    {
        CanMove = canMove;
    }

    public void SetGameOver(bool gameOver)
    {
        isGameOver = gameOver;
    }
}
