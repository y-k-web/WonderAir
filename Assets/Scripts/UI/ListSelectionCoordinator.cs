using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
public sealed class ListSelectionCoordinator : MonoBehaviour
{
    [Tooltip("Optional static entries that will be pre-registered in the displayed order.")]
    [SerializeField] private ListEntryHighlight[] initialEntries = System.Array.Empty<ListEntryHighlight>();
    [SerializeField, Tooltip("Automatically select this entry index when the component becomes active. Set to -1 to skip.")]
    private int defaultSelectionIndex = -1;

    private readonly List<ListEntryHighlight> registeredEntries = new();
    private ListEntryHighlight current;

    private void Awake()
    {
        if (initialEntries == null)
        {
            return;
        }

        foreach (var entry in initialEntries)
        {
            RegisterEntry(entry);
        }
    }

    private void OnEnable()
    {
        if (current != null)
        {
            current.SetSelected(true);
            return;
        }

        if (defaultSelectionIndex >= 0)
        {
            SelectByIndex(defaultSelectionIndex);
        }
    }

    public void RegisterEntry(ListEntryHighlight entry)
    {
        if (!entry)
        {
            return;
        }

        if (registeredEntries.Contains(entry))
        {
            entry.AttachCoordinator(this);
            return;
        }

        registeredEntries.Add(entry);
        entry.AttachCoordinator(this);
    }

    public void UnregisterEntry(ListEntryHighlight entry)
    {
        if (!entry)
        {
            return;
        }

        if (registeredEntries.Remove(entry) && current == entry)
        {
            current = null;
        }
    }

    internal void RequestSelection(ListEntryHighlight entry)
    {
        if (!entry)
        {
            return;
        }

        if (current == entry)
        {
            entry.SetSelected(true);
            return;
        }

        if (current)
        {
            current.SetSelected(false);
        }

        current = entry;
        current.SetSelected(true);
    }

    public void SelectEntry(ListEntryHighlight entry)
    {
        RequestSelection(entry);
    }

    public void SelectByIndex(int index)
    {
        if (index < 0)
        {
            ClearSelection();
            return;
        }

        ListEntryHighlight entry = null;

        if (initialEntries != null && index < initialEntries.Length)
        {
            entry = initialEntries[index];
        }

        if (!entry && index < registeredEntries.Count)
        {
            entry = registeredEntries[index];
        }

        if (!entry)
        {
            Debug.LogWarning($"ListSelectionCoordinator.SelectByIndex: index {index} is out of range.", this);
            return;
        }

        RequestSelection(entry);
    }

    public void ClearSelection()
    {
        if (!current)
        {
            return;
        }

        current.SetSelected(false);
        current = null;
    }
}
