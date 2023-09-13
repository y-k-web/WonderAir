using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
public class ItemController: MonoBehaviour
{
    public float shrinkSpeed = 10; // 縮小速度
    public float fadeSpeed = 10f;   // 透明度減少速度

    private Vector3 initialScale; // 初期スケール
    private Material material;    // オブジェクトのマテリアル
    private Color initialColor;   // 初期カラー

    private bool isShrinking = false;

    // Start is called before the first frame update
    void Start()
    {
        // オブジェクトの初期スケールを記録
        initialScale = transform.localScale;

        // オブジェクトにRendererコンポーネントがある場合、そのマテリアルを取得
        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            material = renderer.material;
            initialColor = material.color;
        }
    }

    // Update is called once per frame
    void Update()
    {
        // オブジェクトが縮小中である場合
        if (isShrinking)
        {
            ShrinkAndFadeFromCenterPoint();
        }
    }

    public void OnTriggerEnter(Collider other)
    {
        if (this.tag == "Ring" && other.CompareTag("Player"))
        {
            // オブジェクトの縮小と透明度減少を開始
            isShrinking = true;
        }
    }

    private void ShrinkAndFadeFromCenterPoint()
    {
        float fixedDeltaTime = Time.fixedDeltaTime; // 経過時間を固定化

    // 現在のスケールを取得
    float currentScale = transform.localScale.x;

    // 現在の透明度を取得
    Color currentColor = material != null ? material.color : Color.white;

    // 縮小
    float newScale = Mathf.Lerp(currentScale, 0f, fixedDeltaTime * shrinkSpeed);
    transform.localScale = new Vector3(newScale, newScale, newScale);

    // 透明度減少
    Color newColor = new Color(currentColor.r, currentColor.g, currentColor.b, Mathf.Lerp(currentColor.a, 0f, fixedDeltaTime * fadeSpeed));
    if (material != null)
    {
        material.color = newColor;
    }

    // スケールが一定以下になったらオブジェクトを削除
    if (newScale <= 0.01f)
    {
        Destroy(gameObject);
    }
}
}