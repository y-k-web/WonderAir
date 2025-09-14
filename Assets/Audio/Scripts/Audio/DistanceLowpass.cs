using UnityEngine;
using UnityEngine.Audio;

// Controls a global lowpass filter exposed on the mixer based on
// distance between this object and the AudioListener.
public class DistanceLowpass : MonoBehaviour
{
    public AudioMixer mixer;
    [Tooltip("Name of exposed parameter controlling cutoff frequency.")]
    public string exposedParam = "SFX_LPF_Cutoff";
    public Transform listener;
    public float startDistance = 5f, endDistance = 40f;
    public float nearCutoff = 22000f, farCutoff = 4000f;
    public float smoothTime = 0.08f;

    float _vel, _current;

    void Awake()
    {
        if (!listener)
        {
            var al = FindObjectOfType<AudioListener>();
            if (al) listener = al.transform;
        }
        _current = nearCutoff;
        if (mixer) mixer.SetFloat(exposedParam, nearCutoff);
    }

    void Update()
    {
        if (!listener || !mixer) return;
        float d = Vector3.Distance(listener.position, transform.position);
        float t = Mathf.InverseLerp(startDistance, endDistance, d);
        float target = Mathf.Lerp(nearCutoff, farCutoff, t);
        _current = Mathf.SmoothDamp(_current, target, ref _vel, smoothTime);
        mixer.SetFloat(exposedParam, _current);
    }
}
