using UnityEngine;

// Simple raycast-based occlusion that dampens volume and applies a per-source
// lowpass filter when the listener is behind an obstacle.
[RequireComponent(typeof(AudioSource))]
public class SimpleOcclusion : MonoBehaviour
{
    public Transform listener;
    public LayerMask occluders;
    public AudioLowPassFilter perSourceLPF;
    public float minCutoff = 800f, maxCutoff = 22000f;
    public float occludedVol = 0.5f, normalVol = 1f;
    public float smoothTime = 0.1f;

    AudioSource _src;
    float _cut, _cutVel, _vol, _volVel;

    void Awake()
    {
        _src = GetComponent<AudioSource>();
        if (!listener)
        {
            var al = FindObjectOfType<AudioListener>();
            if (al) listener = al.transform;
        }
        _cut = maxCutoff; _vol = normalVol;
        if (perSourceLPF) perSourceLPF.cutoffFrequency = _cut;
        _src.volume = _vol;
    }

    void Update()
    {
        if (!listener) return;
        Vector3 dir = listener.position - transform.position;
        bool blocked = Physics.Raycast(transform.position, dir.normalized, out var hit, dir.magnitude, occluders);
        float targetCut = blocked ? minCutoff : maxCutoff;
        float targetVol = blocked ? occludedVol : normalVol;

        _cut = Mathf.SmoothDamp(_cut, targetCut, ref _cutVel, smoothTime);
        _vol = Mathf.SmoothDamp(_vol, targetVol, ref _volVel, smoothTime);

        if (perSourceLPF) perSourceLPF.cutoffFrequency = _cut;
        _src.volume = _vol;
    }
}
