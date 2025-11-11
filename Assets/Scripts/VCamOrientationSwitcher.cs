using UnityEngine;
using Cinemachine;

public class VCamOrientationSwitcher : MonoBehaviour
{
    public CinemachineVirtualCamera vcam;

    [Header("Portrait (縦) 設定")]
    public float fovPortrait = 52f;
    public Vector3 offsetPortrait = new Vector3(0f, 2f, 2f);

    [Header("Landscape (横) 設定")]
    public float fovLandscape = 60f;
    public Vector3 offsetLandscape = new Vector3(0f, 1.58f, 3.18f);

    int _lastW, _lastH;
    bool _dirty;

    void Reset() => vcam = GetComponent<CinemachineVirtualCamera>();

    void OnEnable()
    {
        _lastW = Screen.width;
        _lastH = Screen.height;
        _dirty = true; // 初回反映
    }

    void Update()
    {
        // 画面サイズ変化を検知して「更新必要」のフラグだけ立てる
        if (_lastW != Screen.width || _lastH != Screen.height)
        {
            _lastW = Screen.width;
            _lastH = Screen.height;
            _dirty = true;
        }
    }

    void LateUpdate()
    {
        // 同フレーム後半で確実に上書きして、他の処理に負けないようにする
        if (_dirty) { ApplyByCurrentOrientation(); _dirty = false; }
    }

    public bool IsPortrait() => Screen.height >= Screen.width;

    public float GetDefaultFieldOfView(bool? portrait = null)
    {
        bool isPortrait = portrait ?? IsPortrait();
        return isPortrait ? fovPortrait : fovLandscape;
    }

    void ApplyByCurrentOrientation()
    {
        if (vcam == null) return;

        bool isPortrait = IsPortrait();

        // FOV（正投影なら OrthographicSize を使う）
        var lens = vcam.m_Lens;
        if (!lens.Orthographic)
            lens.FieldOfView = GetDefaultFieldOfView(isPortrait);
        else
            lens.OrthographicSize = isPortrait ? 6.0f : 5.0f;
        vcam.m_Lens = lens;

        // Framing Transposer 優先でオフセットを反映
        var framing = vcam.GetCinemachineComponent<CinemachineFramingTransposer>();
        if (framing != null)
        {
            framing.m_TrackedObjectOffset = isPortrait ? offsetPortrait : offsetLandscape;
            return;
        }

        var transposer = vcam.GetCinemachineComponent<CinemachineTransposer>();
        if (transposer != null)
        {
            transposer.m_FollowOffset = isPortrait ? offsetPortrait : offsetLandscape;
        }
    }
}
