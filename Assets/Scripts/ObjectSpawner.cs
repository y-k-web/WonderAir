using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectSpawner : MonoBehaviour
{
    public GameObject[] keyPrefabs; // 4つのKeyのプレハブを格納する配列
    public BoxCollider boundary; // スポーン範囲を定義するBoundary
    public float spawnRadius = 0.5f; // 半径のコリジョンチェック
    public LayerMask blockingLayers = ~0; // スポーンをブロックするレイヤーマスク

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

        Bounds bounds = boundary.bounds;
        const int maxAttempts = 20;
        Vector3 candidate = bounds.center;

        for (int i = 0; i < maxAttempts; i++)
        {
            float randomX = Random.Range(bounds.min.x, bounds.max.x);
            float randomY = Random.Range(bounds.min.y, bounds.max.y);
            float randomZ = Random.Range(bounds.min.z, bounds.max.z);

            candidate = new Vector3(randomX, randomY, randomZ);

            if (!Physics.CheckSphere(candidate, spawnRadius, blockingLayers, QueryTriggerInteraction.Ignore))
            {
                return candidate;
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
