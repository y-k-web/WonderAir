using System.Collections.Generic;
using UnityEngine;

public class UIHandler : MonoBehaviour
{
    public static UIHandler Instance { get; private set; }

    public Camera mainCamera; // MainCameraをインスペクタからアサインします
    public Canvas verticalCanvas; // 縦向きのときに表示するキャンバス
    public Canvas horizontalCanvas; // 横向きのときに表示するキャンバス

    public float verticalFOV = 100f; // 縦向きの時のカメラのFOV
    public float horizontalFOV = 50f; // 横向きの時のカメラのFOV

    private readonly List<OrientationPair> orientationPairs = new();

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        RegisterOrientationObjects(verticalCanvas.gameObject, horizontalCanvas.gameObject);
    }

    private void Update()
    {
        bool isVertical = IsPortrait();
        mainCamera.fieldOfView = isVertical ? verticalFOV : horizontalFOV;

        foreach (var pair in orientationPairs)
        {
            if (pair.vertical != null) pair.vertical.SetActive(isVertical);
            if (pair.horizontal != null) pair.horizontal.SetActive(!isVertical);
        }
    }

    public void RegisterOrientationObjects(GameObject vertical, GameObject horizontal)
    {
        orientationPairs.Add(new OrientationPair(vertical, horizontal));
        bool isVertical = IsPortrait();
        if (vertical != null) vertical.SetActive(isVertical);
        if (horizontal != null) horizontal.SetActive(!isVertical);
    }

    public bool IsPortrait()
    {
        return Screen.orientation == ScreenOrientation.Portrait ||
               Screen.orientation == ScreenOrientation.PortraitUpsideDown;
    }

    private struct OrientationPair
    {
        public GameObject vertical;
        public GameObject horizontal;

        public OrientationPair(GameObject v, GameObject h)
        {
            vertical = v;
            horizontal = h;
        }
    }
}
