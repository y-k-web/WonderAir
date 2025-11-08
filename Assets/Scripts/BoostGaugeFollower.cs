using UnityEngine;

[RequireComponent(typeof(RectTransform))]
public class BoostGaugeFollower : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private Vector3 localOffset = new Vector3(0.8f, 1.2f, 0f);
    [SerializeField] private Vector2 screenOffset = new Vector2(80f, 0f);
    [SerializeField] private Canvas parentCanvas;

    private RectTransform rectTransform;

    private void Awake()
    {
        rectTransform = GetComponent<RectTransform>();
        if (!parentCanvas)
        {
            parentCanvas = GetComponentInParent<Canvas>();
        }
    }

    private void LateUpdate()
    {
        if (!target)
        {
            return;
        }

        var canvas = parentCanvas ? parentCanvas : GetComponentInParent<Canvas>();
        if (!canvas)
        {
            return;
        }

        var camera = canvas.renderMode == RenderMode.ScreenSpaceOverlay ? Camera.main : canvas.worldCamera;
        if (!camera)
        {
            camera = Camera.main;
        }

        if (!camera)
        {
            return;
        }

        Vector3 worldPosition = target.position
            + target.right * localOffset.x
            + target.up * localOffset.y
            + target.forward * localOffset.z;

        Vector3 screenPosition = camera.WorldToScreenPoint(worldPosition);
        if (screenPosition.z < 0f)
        {
            return;
        }

        screenPosition += (Vector3)screenOffset;

        if (canvas.transform is not RectTransform canvasRect)
        {
            return;
        }

        if (RectTransformUtility.ScreenPointToLocalPointInRectangle(
                canvasRect,
                screenPosition,
                canvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : camera,
                out Vector2 anchoredPosition))
        {
            rectTransform.anchoredPosition = anchoredPosition;
        }
    }

    public void SetTarget(Transform newTarget)
    {
        target = newTarget;
    }

    public void SetCanvas(Canvas canvas)
    {
        parentCanvas = canvas;
    }
}
