using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class ScoreManager : MonoBehaviour
{
    // public TextMeshProUGUI scoreText;
    public TextMeshProUGUI scoreTextVertical;
    public TextMeshProUGUI scoreTextHorizontal;
    public TextMeshProUGUI chainTextVertical;
    public TextMeshProUGUI chainTextHorizontal;
    public TextMeshProUGUI keyCountTextVertical;
    public TextMeshProUGUI keyCountTextHorizontal;
    public TextMeshProUGUI scoreResultVertical;
    public TextMeshProUGUI scoreResultHorizontal;
    public GameObject Portal;
    public GameObject ItemSet;
    public ObjectSpawner objectSpawner;

    private int keyCount = 0;
    private int score = 0;
    private int lastSpawnScore = 0;
    private int chainCount = 0;
    private float lastItemTime;
    public float chainTime = 0.5f;
    public float chainMultiplier = 1.25f;

    private int[] scoreThresholds = { 1000, 2000, 3000, 4000 };
    private bool[] hasSpawned = { false, false, false, false };

    private void Start()
    {
        lastItemTime = -chainTime;
        chainTextHorizontal.gameObject.SetActive(false);
        chainTextVertical.gameObject.SetActive(false);
        UpdateKeyCountText();
    }

    private void Update()
    {
        if (Time.time > lastItemTime + chainTime)
        {
            chainTextHorizontal.gameObject.SetActive(false);
            chainTextVertical.gameObject.SetActive(false);
        }

        // スコアが閾値を超える場合にオブジェクトをスポーン
        // if (score - lastSpawnScore >= 1000)
        // {
        //     lastSpawnScore = score;
        //     objectSpawner.SpawnObject();
        // }

        // スコアが特定の閾値を超える場合にオブジェクトをスポーン
        for (int i = 0; i < scoreThresholds.Length; i++)
        {
            if (score > scoreThresholds[i] && !hasSpawned[i])
            {
                objectSpawner.SpawnObject();
                hasSpawned[i] = true;
            }
        }
    }

    public void CollectKey()
    {
        keyCount++;
        score += 200;
        UpdateScoreText();
        UpdateKeyCountText();

        if (keyCount >= 4)
        {
            SpawnNewObject();
        }
    }

    private void UpdateKeyCountText()
    {
        keyCountTextVertical.text = "Key:" + keyCount;
        keyCountTextHorizontal.text = "Key:" + keyCount;
    }

    public void AddScore(int amount)
    {
        float timeSinceLastItem = Time.time - lastItemTime;

        if (timeSinceLastItem <= chainTime)
        {
            chainCount++;
            if (chainCount >= 2)
            {
                amount = Mathf.RoundToInt(amount * chainMultiplier);
                chainTextVertical.gameObject.SetActive(true);
                chainTextHorizontal.gameObject.SetActive(true);
            }
        }
        else
        {
            chainCount = 1;
        }

        score += amount;
        UpdateScoreText();
        UpdateChainText();
        lastItemTime = Time.time;
    }

    private void UpdateScoreText()
    {
        scoreTextVertical.text = "Score: " + score;
        scoreTextHorizontal.text = "Score: " + score;
    }

    private void UpdateChainText()
    {
        chainTextVertical.text = (chainCount >= 2 ? chainCount - 1 : 0) + "Chain!";
        chainTextHorizontal.text = (chainCount >= 2 ? chainCount - 1 : 0) + "Chain!";
    }

    private void SpawnNewObject()
    {
        // ランダムなXとZ座標を計算
        float randomX = Random.Range(objectSpawner.minX, objectSpawner.maxX);
        float randomZ = Random.Range(objectSpawner.minZ, objectSpawner.maxZ);

        // 地形の高さをXとZの位置でサンプリング
        Terrain terrain = Terrain.activeTerrain;
        float terrainHeight = terrain.SampleHeight(new Vector3(randomX, 0, randomZ));

        // Y座標の最小値として地形の高さを使用し、最大値としてobjectSpawner.maxYを使用してランダムな値を取得
        float randomY = Random.Range(terrainHeight, objectSpawner.maxY);

        Vector3 randomPosition = new Vector3(randomX, randomY, randomZ);

        GameObject spawnedPortal = Instantiate(Portal, randomPosition, Quaternion.identity);
        spawnedPortal.SetActive(false);

        spawnedPortal.SetActive(true);

        // ItemSet オブジェクトを生成し、非アクティブにする
        ItemSet = Instantiate(ItemSet);
        ItemSet.SetActive(false); // 最初は非アクティブにする

        ItemSet.SetActive(true);
    }
    public void UpdateGameOverScoreText()
    {
        string result = "Score: " + score;
        scoreResultVertical.text = result;
        scoreResultHorizontal.text = result;
    }
}
