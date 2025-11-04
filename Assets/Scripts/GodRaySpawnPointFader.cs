using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Collider))]
public class GodRaySpawnPointFader : MonoBehaviour
{
    [SerializeField] private GameObject spawnPointRoot;
    [SerializeField] private float fadeDuration = 1f;
    [SerializeField] private string targetTag = "Player";

    private readonly List<Renderer> _renderers = new List<Renderer>();
    private readonly List<ParticleSystem> _particleSystems = new List<ParticleSystem>();
    private readonly List<Material> _materials = new List<Material>();
    private readonly List<Color> _originalColors = new List<Color>();
    private bool _isFading;
    private Collider _collider;

    private void Reset()
    {
        _collider = GetComponent<Collider>();
        if (_collider != null)
        {
            _collider.isTrigger = true;
        }

        if (spawnPointRoot == null && transform.parent != null)
        {
            spawnPointRoot = transform.parent.gameObject;
        }
    }

    private void Awake()
    {
        _collider = GetComponent<Collider>();
        if (_collider != null && !_collider.isTrigger)
        {
            Debug.LogWarning($"{nameof(GodRaySpawnPointFader)} on {name} expects the collider to be marked as trigger.", this);
        }

        if (spawnPointRoot == null && transform.parent != null)
        {
            spawnPointRoot = transform.parent.gameObject;
        }

        if (spawnPointRoot == null)
        {
            Debug.LogWarning($"{nameof(GodRaySpawnPointFader)} on {name} has no spawn point assigned.", this);
            return;
        }

        CacheSpawnPointRenderers();
    }

    private void CacheSpawnPointRenderers()
    {
        _renderers.Clear();
        _particleSystems.Clear();
        _materials.Clear();
        _originalColors.Clear();

        _renderers.AddRange(spawnPointRoot.GetComponentsInChildren<Renderer>(true));
        _particleSystems.AddRange(spawnPointRoot.GetComponentsInChildren<ParticleSystem>(true));

        foreach (var renderer in _renderers)
        {
            foreach (var material in renderer.materials)
            {
                if (TryGetColor(material, out var color))
                {
                    _materials.Add(material);
                    _originalColors.Add(color);
                }
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        HandleExit(other.gameObject);
    }

    private void OnCollisionExit(Collision collision)
    {
        HandleExit(collision.gameObject);
    }

    private void HandleExit(GameObject other)
    {
        if (_isFading || spawnPointRoot == null)
        {
            return;
        }

        if (!string.IsNullOrEmpty(targetTag) && !other.CompareTag(targetTag))
        {
            return;
        }

        StartCoroutine(FadeOut());
    }

    private IEnumerator FadeOut()
    {
        _isFading = true;

        float elapsed = 0f;
        if (fadeDuration <= 0f)
        {
            ApplyAlpha(0f);
            yield return null;
        }
        else
        {
            while (elapsed < fadeDuration)
            {
                float t = Mathf.Clamp01(elapsed / fadeDuration);
                ApplyAlpha(1f - t);
                elapsed += Time.deltaTime;
                yield return null;
            }
            ApplyAlpha(0f);
        }

        foreach (var ps in _particleSystems)
        {
            if (ps != null)
            {
                ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            }
        }

        if (spawnPointRoot != null)
        {
            var rootToDeactivate = spawnPointRoot.transform.parent != null
                ? spawnPointRoot.transform.parent.gameObject
                : spawnPointRoot;
            rootToDeactivate.SetActive(false);
        }
    }

    private void ApplyAlpha(float normalizedAlpha)
    {
        for (int i = 0; i < _materials.Count; i++)
        {
            var originalColor = _originalColors[i];
            var newColor = new Color(
                originalColor.r,
                originalColor.g,
                originalColor.b,
                originalColor.a * Mathf.Clamp01(normalizedAlpha));
            SetColor(_materials[i], newColor);
        }
    }

    private static bool TryGetColor(Material material, out Color color)
    {
        if (material == null)
        {
            color = default;
            return false;
        }

        if (material.HasProperty("_BaseColor"))
        {
            color = material.GetColor("_BaseColor");
            return true;
        }

        if (material.HasProperty("_Color"))
        {
            color = material.GetColor("_Color");
            return true;
        }

        color = default;
        return false;
    }

    private static void SetColor(Material material, Color color)
    {
        if (material == null)
        {
            return;
        }

        if (material.HasProperty("_BaseColor"))
        {
            material.SetColor("_BaseColor", color);
        }

        if (material.HasProperty("_Color"))
        {
            material.SetColor("_Color", color);
        }
    }
}
