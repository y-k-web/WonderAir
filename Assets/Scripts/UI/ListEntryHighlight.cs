using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

[DisallowMultipleComponent]
[RequireComponent(typeof(Selectable))]
public sealed class ListEntryHighlight : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, ISelectHandler, IDeselectHandler
{
    [Header("Highlight visuals")]
    [SerializeField] private Graphic highlightGraphic;
    [SerializeField] private GameObject highlightObject;
    [SerializeField] private Color highlightedColor = new Color(0.94f, 0.94f, 0.94f, 1f);
    [SerializeField, Tooltip("When false the target graphic will retain its original colour.")]
    private bool tintGraphic = true;

    private ListSelectionCoordinator coordinator;
    private Selectable selectable;
    private Color originalColor;
    private bool colorCaptured;
    private bool isPointerInside;
    private bool isSelected;

    private void Awake()
    {
        selectable = GetComponent<Selectable>();
        if (!highlightGraphic && selectable)
        {
            highlightGraphic = selectable.targetGraphic;
        }

        coordinator = GetComponentInParent<ListSelectionCoordinator>();
        coordinator?.RegisterEntry(this);

        CaptureOriginalColor();
    }

    private void OnEnable()
    {
        CaptureOriginalColor();
        UpdateVisual();
    }

    private void OnDisable()
    {
        isPointerInside = false;
        isSelected = false;
        UpdateVisual();
    }

    private void OnDestroy()
    {
        coordinator?.UnregisterEntry(this);
    }

    public void HandleClick()
    {
        if (!IsInteractable())
        {
            return;
        }

        if (coordinator != null)
        {
            coordinator.RequestSelection(this);
        }
        else
        {
            SetSelected(true);
        }
    }

    internal void AttachCoordinator(ListSelectionCoordinator listCoordinator)
    {
        coordinator = listCoordinator;
    }

    internal void SetSelected(bool selected)
    {
        isSelected = selected;
        UpdateVisual();
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        if (!IsInteractable())
        {
            return;
        }

        isPointerInside = true;
        UpdateVisual();
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        if (!IsInteractable())
        {
            return;
        }

        isPointerInside = false;
        UpdateVisual();
    }

    public void OnSelect(BaseEventData eventData)
    {
        if (!IsInteractable())
        {
            return;
        }

        if (coordinator != null)
        {
            coordinator.RequestSelection(this);
        }
        else
        {
            SetSelected(true);
        }
    }

    public void OnDeselect(BaseEventData eventData)
    {
        if (coordinator == null)
        {
            SetSelected(false);
        }
    }

    private void UpdateVisual()
    {
        var highlight = (isPointerInside && IsInteractable()) || isSelected;

        if (highlightObject)
        {
            if (highlightObject.activeSelf != highlight)
            {
                highlightObject.SetActive(highlight);
            }
        }

        if (highlightGraphic && tintGraphic)
        {
            CaptureOriginalColor();
            highlightGraphic.color = highlight ? highlightedColor : originalColor;
        }
    }

    private bool IsInteractable()
    {
        return selectable == null || selectable.IsInteractable();
    }

    private void CaptureOriginalColor()
    {
        if (!tintGraphic || !highlightGraphic || colorCaptured)
        {
            return;
        }

        originalColor = highlightGraphic.color;
        colorCaptured = true;
    }
}
