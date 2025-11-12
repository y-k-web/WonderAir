using UnityEngine;

public class ObjectSpawner : MonoBehaviour
{
    public GameObject[] keyPrefabs; // 4つのKeyのプレハブを格納する配列
    public BoxCollider boundary; // スポーン範囲を定義するBoundary
    public float spawnRadius = 0.5f; // 半径のコリジョンチェック
    public LayerMask blockingLayers = ~0; // スポーンをブロックするレイヤーマスク
    public LayerMask surfaceLayers = ~0; // スポーンさせたい面を取得するためのレイヤーマスク
    [Min(0f)] public float surfaceOffset = 0.05f; // ヒットした面からキーを浮かせる高さ
    [Min(0f)] public float raycastPadding = 0.5f; // レイキャスト開始位置の余裕

    private int objectsCollected = 0;
    private int currentKeyIndex = 0; // 現在のKeyのインデックス

    private void Awake()
    {
        if (boundary == null)
        {
            GameObject boundaryObject = GameObject.FindWithTag("boundary");
            if (boundaryObject != null)
            {
                boundary = boundaryObject.GetComponent<BoxCollider>();
            }
        }

        if (boundary == null)
        {
            Debug.LogError("Boundary not set for ObjectSpawner.");
        }
    }

    public Vector3 GetRandomPosition()
    {
        if (boundary == null)
        {
            Debug.LogError("Boundary not set for ObjectSpawner.");
            return Vector3.zero;
        }

        const int maxAttempts = 20;
        Bounds bounds = boundary.bounds;
        Vector3 candidate = bounds.center;
        float maxRayDistance = bounds.size.y + raycastPadding * 2f;

        for (int attempt = 0; attempt < maxAttempts; attempt++)
        {
            float randomX = Random.Range(bounds.min.x, bounds.max.x);
            float randomZ = Random.Range(bounds.min.z, bounds.max.z);
            float startY = bounds.max.y + raycastPadding;
            Vector3 rayOrigin = new Vector3(randomX, startY, randomZ);

            if (Physics.Raycast(rayOrigin, Vector3.down, out RaycastHit hit, maxRayDistance, surfaceLayers, QueryTriggerInteraction.Ignore))
            {
                Vector3 projected = hit.point + Vector3.up * surfaceOffset;
                Collider hitCollider = hit.collider;
                bool blocked = false;
                Collider[] overlaps = Physics.OverlapSphere(projected, spawnRadius, blockingLayers, QueryTriggerInteraction.Ignore);

                for (int i = 0; i < overlaps.Length; i++)
                {
                    Collider overlap = overlaps[i];

                    if (overlap == hitCollider)
                    {
                        continue;
                    }

                    if (hitCollider != null && overlap.transform.IsChildOf(hitCollider.transform))
                    {
                        continue;
                    }

                    if (hitCollider != null && hitCollider.transform.IsChildOf(overlap.transform))
                    {
                        continue;
                    }

                    blocked = true;
                    break;
                }

                if (!blocked)
                {
                    candidate = projected;
                    return candidate;
                }
            }
        }

        Debug.LogWarning($"No valid spawn position found after {maxAttempts} attempts. Returning last candidate: {candidate}");
        return candidate;
    }

    public void SpawnObject()
    {
        if (objectsCollected >= 4)
        {
            return;
        }

        Vector3 randomPosition = GetRandomPosition();

        GameObject prefabToSpawn = keyPrefabs[currentKeyIndex];
        GameObject spawnedObject = Instantiate(prefabToSpawn, randomPosition, Quaternion.identity);
        spawnedObject.SetActive(false);

        spawnedObject.SetActive(true);

        Debug.Log("Object spawned at position: " + randomPosition);

        objectsCollected++;
        currentKeyIndex++;

        if (currentKeyIndex >= keyPrefabs.Length)
        {
            currentKeyIndex = 0;
        }
    }
}
