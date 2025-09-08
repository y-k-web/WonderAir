using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectSpawner : MonoBehaviour
{
    public GameObject[] keyPrefabs; // 4つのKeyのプレハブを格納する配列
    [SerializeField] private BoxCollider boundaryCollider;

    private int objectsCollected = 0;
    private int currentKeyIndex = 0; // 現在のKeyのインデックス

    private void Awake()
    {
        if (boundaryCollider == null)
        {
            GameObject boundaryObj = GameObject.FindGameObjectWithTag("boundary");
            if (boundaryObj != null)
            {
                boundaryCollider = boundaryObj.GetComponent<BoxCollider>();
            }
        }
    }

    public void SpawnObject()
    {
        if(objectsCollected >= 4){
            return;
        }

        Bounds bounds = boundaryCollider.bounds;

        // ランダムなXとZ座標を計算
        float randomX = Random.Range(bounds.min.x, bounds.max.x);
        float randomZ = Random.Range(bounds.min.z, bounds.max.z);

        // 地形の高さをXとZの位置でサンプリング
        Terrain terrain = Terrain.activeTerrain;
        float terrainHeight = terrain.SampleHeight(new Vector3(randomX, 0, randomZ));

        // Y座標の最小値として地形の高さを使用し、最大値としてboundaryの上限を使用
        float minY = Mathf.Max(bounds.min.y, terrainHeight);
        float randomY = Random.Range(minY, bounds.max.y);

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
