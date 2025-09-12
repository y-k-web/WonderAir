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

                const int maxAttempts = 20;
                Vector3 candidate = Vector3.zero;
                Vector3 center = boundary.center;
                Vector3 size = boundary.size;
                for (int i = 0; i < maxAttempts; i++)
                {
                    Vector3 localOffset = new Vector3(
                        Random.Range(-size.x * 0.5f, size.x * 0.5f),
                        Random.Range(-size.y * 0.5f, size.y * 0.5f),
                        Random.Range(-size.z * 0.5f, size.z * 0.5f)
                    );
                    candidate = boundary.transform.TransformPoint(center + localOffset);

                    if (!Physics.CheckSphere(candidate, spawnRadius, blockingLayers))
                    {
                        return candidate;
                    }
                }

                Debug.LogWarning($"No valid spawn position found after {maxAttempts} attempts. Returning last candidate: {candidate}");
                return candidate;
        }

            public void SpawnObject()
            {
                if(objectsCollected >= 4){
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
