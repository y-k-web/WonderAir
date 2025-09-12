        using System.Collections;
        using System.Collections.Generic;
        using UnityEngine;

        public class ObjectSpawner : MonoBehaviour
        {
            public GameObject[] keyPrefabs; // 4つのKeyのプレハブを格納する配列
            public float minX;
            public float maxX;
            public float minY;
            public float maxY;
            public float minZ; // 最小Z座標
            public float maxZ; // 最大Z座標

            private int objectsCollected = 0;
            private int currentKeyIndex = 0; // 現在のKeyのインデックス

            public void SpawnObject()
            {
                if(objectsCollected >= 4){
                    return;
                }
                // ランダムなXとZ座標を計算
                float randomX = Random.Range(minX, maxX);
                float randomZ = Random.Range(minZ, maxZ);

                // 地形の高さをXとZの位置でサンプリング
                Terrain terrain = Terrain.activeTerrain;
                float terrainHeight = terrain.SampleHeight(new Vector3(randomX, 0, randomZ));

                // Y座標の最小値として地形の高さを使用し、最大値としてmaxYを使用してランダムな値を取得
                float randomY = Random.Range(terrainHeight, maxY);

                Vector3 randomPosition = new Vector3(randomX, randomY, randomZ);

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
