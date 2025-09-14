using UnityEngine;
using UnityEngine.Audio;

// Handles transitions between configured audio mixer snapshots.
public class AudioSnapshotsController : MonoBehaviour
{
    public AudioMixer mixer;
    public AudioMixerSnapshot outdoor;
    public AudioMixerSnapshot indoor;
    public AudioMixerSnapshot pauseSnapshot;
    public float transitionTime = 1.0f;

    public void SetOutdoor() => outdoor?.TransitionTo(transitionTime);
    public void SetIndoor() => indoor?.TransitionTo(transitionTime);
    public void SetPause() => pauseSnapshot?.TransitionTo(transitionTime);
}
