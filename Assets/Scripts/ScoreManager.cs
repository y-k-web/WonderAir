using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;
using UnityEngine.Serialization;

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
    [FormerlySerializedAs("Portal")]
    [SerializeField] private GameObject portalPrefab;
    [FormerlySerializedAs("ItemSet")]
    [SerializeField] private GameObject itemSet1;
    [SerializeField] private GameObject itemSet2;
    public ObjectSpawner objectSpawner;
    [SerializeField] private TimerController timerController; // タイマー制御

    private int keyCount = 0;
    private int score = 0;
    private int lastSpawnScore = 0;
    private int chainCount = 0;
    private float lastItemTime;
    public float chainTime = 0.5f;
    public float chainMultiplier = 1.25f;

    private int[] scoreThresholds = { 1000, 2000, 3000, 4000 };
    private bool[] hasSpawned = { false, false, false, false };

    private GameObject activePortal;

    private AudioSource bgmSource;
    private AudioSource sfxSource;
    private AudioClip[] chainClips;
    private AudioClip lastPickupClip;

    [SerializeField, Range(0f, 1f)] private float bgmVolume = 1f;
    [SerializeField] private float bgmStartTime = 0f;
    [SerializeField, Range(0f, 1f)] private float sfxVolume = 1f;

    private void Start()
    {
        lastItemTime = -chainTime;
        chainTextHorizontal.gameObject.SetActive(false);
        chainTextVertical.gameObject.SetActive(false);
        UpdateKeyCountText();

        if (itemSet1 != null)
        {
            itemSet1.SetActive(true);
        }

        if (itemSet2 != null)
        {
            itemSet2.SetActive(false);
        }

        chainTextHorizontal.gameObject.SetActive(false);
        chainTextVertical.gameObject.SetActive(false);

        if (timerController == null)
        {
            timerController = FindObjectOfType<TimerController>();
        }

        InitializeAudio();
    }

    private void Update()
    {
        if (Time.time > lastItemTime + chainTime)
        {
            if (chainCount >= 2 && timerController != null && !IsPortalActive())
            {
                int chainSeconds = chainCount; // チェイン数分加算
                timerController.AddTime(chainSeconds);
            }

            chainCount = 0;
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

    public void AddScore(int amount, bool playSound)
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

        if (playSound)
        {
            PlayChainSound();
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
        chainTextVertical.text = (chainCount >= 2 ? chainCount : 0) + "Chain!";
        chainTextHorizontal.text = (chainCount >= 2 ? chainCount : 0) + "Chain!";
    }

    private void SpawnNewObject()
    {
        Vector3 randomPosition = objectSpawner.GetRandomPosition();

        if (portalPrefab != null)
        {
            activePortal = Instantiate(portalPrefab, randomPosition, Quaternion.identity);
            activePortal.SetActive(false);
            activePortal.SetActive(true);
        }

        if (itemSet1 != null)
        {
            itemSet1.SetActive(false);
        }

        if (itemSet2 != null)
        {
            itemSet2.SetActive(true);
        }

        chainTextVertical.gameObject.SetActive(false);
        chainTextHorizontal.gameObject.SetActive(false);
    }
    public void UpdateGameOverScoreText()
    {
        string result = "Score: " + score;
        scoreResultVertical.text = result;
        scoreResultHorizontal.text = result;
    }

    private void InitializeAudio()
    {
        if (SceneManager.GetActiveScene().name != "Stage1")
        {
            return;
        }

        bgmSource = gameObject.AddComponent<AudioSource>();
        sfxSource = gameObject.AddComponent<AudioSource>();

        AudioClip bgm = Resources.Load<AudioClip>("Sounds/Sky Parade");
        if (bgm != null)
        {
            bgmSource.clip = bgm;
            bgmSource.loop = true;
            bgmSource.volume = bgmVolume;
            bgmSource.time = Mathf.Clamp(bgmStartTime, 0f, bgm.length);
            bgmSource.Play();
        }

        // string[] names = { "one", "two", "three", "four", "five", "six" };
        string[] names = {"one"};
        chainClips = new AudioClip[names.Length];
        for (int i = 0; i < names.Length; i++)
        {
            chainClips[i] = Resources.Load<AudioClip>("Sounds/" + names[i]);
        }
    }

    private void PlayChainSound()
    {
        if (sfxSource == null || chainClips == null || chainClips.Length == 0)
        {
            return;
        }

        if (chainCount > 1)
        {
            int index = Random.Range(0, chainClips.Length);
            lastPickupClip = chainClips[index];
        }
        else if (lastPickupClip == null)
        {
            int index = Random.Range(0, chainClips.Length);
            lastPickupClip = chainClips[index];
        }

        if (lastPickupClip != null)
        {
            sfxSource.PlayOneShot(lastPickupClip, sfxVolume);
        }
    }

    private bool IsPortalActive()
    {
        return activePortal != null && activePortal.activeInHierarchy;
    }
}
