using UnityEngine;
using UnityEngine.UI; 
public class UIHandler : MonoBehaviour
{
    public Camera mainCamera; // MainCameraをインスペクタからアサインします
    public Canvas verticalCanvas; // 縦向きのときに表示するキャンバス
    public Canvas horizontalCanvas; // 横向きのときに表示するキャンバス
    private CanvasRenderer verticalRenderer; 
    private CanvasRenderer horizontalRenderer;

    public float verticalFOV = 100f; // 縦向きの時のカメラのFOV
    public float horizontalFOV = 50f; // 横向きの時のカメラのFOV

    private void Start()
    {
        // Start時にCanvasRendererコンポーネントを取得
        verticalRenderer = verticalCanvas.GetComponent<CanvasRenderer>();
        horizontalRenderer = horizontalCanvas.GetComponent<CanvasRenderer>();
    }
private void SetCanvasVisibility(Canvas canvas, bool isVisible)
{
    Graphic[] graphics = canvas.GetComponentsInChildren<Graphic>();
    foreach (Graphic graphic in graphics)
    {
        graphic.color = new Color(graphic.color.r, graphic.color.g, graphic.color.b, isVisible ? 1f : 0f);
    }
}

    private void Update()
    {
        UIswitcher();
    }

private void UIswitcher()
{
    TimerController timerController = FindObjectOfType<TimerController>();
    if (Screen.orientation == ScreenOrientation.Portrait ||
        Screen.orientation == ScreenOrientation.PortraitUpsideDown)
    {
        SetCanvasVisibility(verticalCanvas, true);
        SetCanvasVisibility(horizontalCanvas, false);
        mainCamera.fieldOfView = verticalFOV;
        if(timerController != null)
        {
            timerController.SetTimerVisibility(true, false);
        }
    }
    else if (Screen.orientation == ScreenOrientation.LandscapeLeft || 
             Screen.orientation == ScreenOrientation.LandscapeRight)
    {
        SetCanvasVisibility(verticalCanvas, false);
        SetCanvasVisibility(horizontalCanvas, true);
        mainCamera.fieldOfView = horizontalFOV;
        if(timerController != null)
        {
            timerController.SetTimerVisibility(false, true);
        }
    }
}

}
