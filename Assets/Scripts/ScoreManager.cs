using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;

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

    private AudioSource bgmSource;
    private AudioSource sfxSource;
    private AudioClip[] chainClips;

    [SerializeField, Range(0f, 1f)] private float bgmVolume = 1f;
    [SerializeField] private float bgmStartTime = 0f;
    [SerializeField, Range(0f, 1f)] private float sfxVolume = 1f;
    [SerializeField] private float bgmFadeInTime = 1f;
    [SerializeField, Range(0f, 1f)] private float duckVolume = 0.7f;
    [SerializeField] private float duckFadeTime = 0.1f;
    [SerializeField] private float duckDuration = 0.3f;

    private Coroutine duckRoutine;

    private void Start()
    {
        lastItemTime = -chainTime;
        chainTextHorizontal.gameObject.SetActive(false);
        chainTextVertical.gameObject.SetActive(false);
        UpdateKeyCountText();

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
            if (chainCount >= 2 && timerController != null)
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

    private void InitializeAudio()
    {
        if (SceneManager.GetActiveScene().name != "Stage1")
        {
            return;
        }

        bgmSource = gameObject.AddComponent<AudioSource>();
        sfxSource = gameObject.AddComponent<AudioSource>();
        bgmSource.playOnAwake = false;
        sfxSource.playOnAwake = false;
        bgmSource.spatialBlend = 0f;
        sfxSource.spatialBlend = 0f;

        AudioClip bgm = Resources.Load<AudioClip>("Sounds/Sky Parade");
        if (bgm != null)
        {
            bgmSource.clip = bgm;
            bgmSource.loop = true;
            bgmSource.volume = 0f;
            bgmSource.time = Mathf.Clamp(bgmStartTime, 0f, bgm.length);
            bgmSource.Play();
            StartCoroutine(FadeInBgm());
        }

        string[] names = { "one", "two", "three", "four", "five", "six" };
        chainClips = new AudioClip[names.Length];
        for (int i = 0; i < names.Length; i++)
        {
            chainClips[i] = Resources.Load<AudioClip>("Sounds/" + names[i]);
        }
    }
    private IEnumerator FadeInBgm()
    {
        float elapsed = 0f;
        while (elapsed < bgmFadeInTime)
        {
            elapsed += Time.deltaTime;
            bgmSource.volume = Mathf.Lerp(0f, bgmVolume, elapsed / bgmFadeInTime);
            yield return null;
        }
        bgmSource.volume = bgmVolume;
    }

    private void PlayChainSound()
    {
        if (sfxSource == null || chainClips == null || chainClips.Length == 0)
        {
            return;
        }

        int index = Random.Range(0, chainClips.Length);
        AudioClip clip = chainClips[index];
        if (clip != null)
        {
            sfxSource.PlayOneShot(clip, sfxVolume);
            if (duckRoutine != null)
            {
                StopCoroutine(duckRoutine);
            }
            duckRoutine = StartCoroutine(DuckBgm());
        }
    }

    private IEnumerator DuckBgm()
    {
        float target = bgmVolume * duckVolume;
        float startVol = bgmSource.volume;
        float t = 0f;
        while (t < duckFadeTime)
        {
            t += Time.deltaTime;
            bgmSource.volume = Mathf.Lerp(startVol, target, t / duckFadeTime);
            yield return null;
        }
        bgmSource.volume = target;
        yield return new WaitForSeconds(duckDuration);
        t = 0f;
        while (t < duckFadeTime)
        {
            t += Time.deltaTime;
            bgmSource.volume = Mathf.Lerp(target, bgmVolume, t / duckFadeTime);
            yield return null;
        }
        bgmSource.volume = bgmVolume;
    }
}
