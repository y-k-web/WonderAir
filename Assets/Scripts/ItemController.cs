using UnityEngine;

public class ItemController : MonoBehaviour
{
    public float shrinkSpeed = 500f; // 縮小速度
    public float fadeSpeed = 500f;   // 透明度減少速度
    public int ringScore = 100;
    public float boostRecoveryAmount = 10f; // 回復量

    private Vector3 initialScale; // 初期スケール
    private Material material;    // オブジェクトのマテリアル
    private Color initialColor;   // 初期カラー
    private bool isShrinking = false;

    void Start()
    {
        initialScale = transform.localScale;

        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            material = renderer.material;
            initialColor = material.color;
        }
    }

    void Update()
    {
        if (isShrinking)
        {
            ShrinkAndFadeFromCenterPoint();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if ((this.CompareTag("Ring") || this.CompareTag("Key") || this.CompareTag("Gem")) && other.CompareTag("Player"))
        {
            Collider collider = GetComponent<Collider>();
            if (collider != null)
            {
                collider.enabled = false;
            }

            isShrinking = true;
            FindObjectOfType<ScoreManager>().AddScore(ringScore);

            BoostController boostController = other.GetComponent<BoostController>();
            if (boostController != null)
            {
                boostController.RecoverBoost(boostRecoveryAmount);
            }
        }
    }

    private void ShrinkAndFadeFromCenterPoint()
    {
        if (this.CompareTag("Ring"))
        {
            float fixedDeltaTime = Time.fixedDeltaTime;
            float currentScale = transform.localScale.x;
            Color currentColor = material != null ? material.color : Color.white;

            float newScale = Mathf.Lerp(currentScale, 0f, fixedDeltaTime * shrinkSpeed);
            transform.localScale = new Vector3(newScale, newScale, newScale);

            Color newColor = new Color(currentColor.r, currentColor.g, currentColor.b, Mathf.Lerp(currentColor.a, 0f, fixedDeltaTime * fadeSpeed));
            if (material != null)
            {
                material.color = newColor;
            }

            if (newScale <= 0.5f)
            {
                Destroy(gameObject);
            }
        }
    }
}
