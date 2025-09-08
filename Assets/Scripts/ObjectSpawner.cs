        using System.Collections;
        using System.Collections.Generic;
        using UnityEngine;

        public class ObjectSpawner : MonoBehaviour
        {
            public GameObject[] keyPrefabs; // 4つのKeyのプレハブを格納する配列
            public BoxCollider boundary; // スポーン範囲を定義するBoundary

            private float minX;
            private float maxX;
            private float minY;
            private float maxY;
            private float minZ; // 最小Z座標
            private float maxZ; // 最大Z座標

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

                if (boundary != null)
                {
                    Bounds bounds = boundary.bounds;
                    minX = bounds.min.x;
                    maxX = bounds.max.x;
                    minY = bounds.min.y;
                    maxY = bounds.max.y;
                    minZ = bounds.min.z;
                    maxZ = bounds.max.z;
                }
                else
                {
                    Debug.LogError("Boundary not set for ObjectSpawner.");
                }
            }

            public Vector3 GetRandomPosition()
            {
                float randomX = Random.Range(minX, maxX);
                float randomZ = Random.Range(minZ, maxZ);

                // 地形の高さをXとZの位置でサンプリング
                Terrain terrain = Terrain.activeTerrain;
                float terrainHeight = terrain.SampleHeight(new Vector3(randomX, 0, randomZ));

                // Y座標の最小値として地形の高さと境界の最小値の高い方を使用
                float minYAdjusted = Mathf.Max(minY, terrainHeight);
                float randomY = Random.Range(minYAdjusted, maxY);

                return new Vector3(randomX, randomY, randomZ);
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
