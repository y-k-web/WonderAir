#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using UnityEngine.Audio;

// Basic tooling to streamline common audio setup tasks.
public class AudioSetupWizard : EditorWindow
{
    AudioMixer _mixer;
    AudioMixerGroup _music, _sfx, _ambience, _ui;
    float sfxMin = 2f, sfxMax = 30f, ambMin = 3f, ambMax = 60f;

    [MenuItem("Tools/Audio Setup Wizard")]
    static void Init() => GetWindow<AudioSetupWizard>("Audio Setup");

    void OnGUI()
    {
        _mixer = (AudioMixer)EditorGUILayout.ObjectField("Game Mixer", _mixer, typeof(AudioMixer), false);
        _music = (AudioMixerGroup)EditorGUILayout.ObjectField("Music Group", _music, typeof(AudioMixerGroup), false);
        _sfx = (AudioMixerGroup)EditorGUILayout.ObjectField("SFX Group", _sfx, typeof(AudioMixerGroup), false);
        _ambience = (AudioMixerGroup)EditorGUILayout.ObjectField("Ambience Group", _ambience, typeof(AudioMixerGroup), false);
        _ui = (AudioMixerGroup)EditorGUILayout.ObjectField("UI Group", _ui, typeof(AudioMixerGroup), false);

        EditorGUILayout.Space();
        if (GUILayout.Button("Ensure single AudioListener"))
            EnsureSingleListener();

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Selected AudioSource Routing", EditorStyles.boldLabel);
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("Music")) ApplyRouting(_music, false);
        if (GUILayout.Button("SFX")) ApplyRouting(_sfx, true);
        if (GUILayout.Button("Ambience")) ApplyRouting(_ambience, true);
        if (GUILayout.Button("UI")) ApplyRouting(_ui, false);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Distance Defaults", EditorStyles.boldLabel);
        sfxMin = EditorGUILayout.FloatField("SFX Min", sfxMin);
        sfxMax = EditorGUILayout.FloatField("SFX Max", sfxMax);
        ambMin = EditorGUILayout.FloatField("Amb Min", ambMin);
        ambMax = EditorGUILayout.FloatField("Amb Max", ambMax);
        if (GUILayout.Button("Apply Distance Defaults"))
            ApplyDistanceDefaults();
    }

    void EnsureSingleListener()
    {
        var listeners = GameObject.FindObjectsOfType<AudioListener>();
        AudioListener main = null;
        foreach (var l in listeners)
        {
            if (l.GetComponent<Camera>() && l.GetComponent<Camera>().tag == "MainCamera")
                main = l;
        }
        foreach (var l in listeners)
        {
            if (l == main) continue;
            l.enabled = false;
        }
        if (!main && listeners.Length > 0)
            listeners[0].enabled = true;
    }

    void ApplyRouting(AudioMixerGroup group, bool spatial)
    {
        foreach (var obj in Selection.objects)
        {
            var go = obj as GameObject;
            if (!go) continue;
            var src = go.GetComponent<AudioSource>();
            if (!src) continue;
            src.outputAudioMixerGroup = group;
            src.dopplerLevel = 0f;
            src.spatialBlend = spatial ? 1f : 0f;
        }
    }

    void ApplyDistanceDefaults()
    {
        foreach (var obj in Selection.objects)
        {
            var go = obj as GameObject;
            if (!go) continue;
            var src = go.GetComponent<AudioSource>();
            if (!src) continue;
            bool isAmb = src.outputAudioMixerGroup == _ambience;
            src.minDistance = isAmb ? ambMin : sfxMin;
            src.maxDistance = isAmb ? ambMax : sfxMax;
        }
    }
}
#endif
