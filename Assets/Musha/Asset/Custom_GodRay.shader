Shader "Custom/Custom_GodRay"
{
    Properties
    {
        [HDR]
        _Color          ("Color", Color)                    = (1, 1, 1, 1)
        _Transparency   ("Transparency", Range(0, 1))       = 0.5

        [Enum(OFF,0,FRONT,1,BACK,2)]
        _CullMode       ("Cull", int)                       = 0

        _MainTex        ("Texture", 2D)                     = "white" {}
        _MainTexPower   ("Texture Power", Range(0, 1))      = 1

        _Speed_U        ("Speed U", Range(-10, 10))         = 0
        _Speed_V        ("Speed V", Range(-10, 10))         = 0

        _MinDist        ("Min Distance", Float)             = 10
        _MaxDist        ("Max Distance", Float)             = 30
        _CenterX        ("LightShaft中心のX座標", Float)    = 0
        _CenterZ        ("LightShaft中心のZ座標", Float)    = 0
        _MinAlpha       ("Min Alpha", Range(0, 1))          = 0
        _UpperY         ("LightShaft上辺のY座標", Float)    = 1000
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Overlay" "DisableBatching"="True" }
        LOD 100

        Pass
        {
            Blend One OneMinusSrcAlpha
            ZWrite Off
            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex   : POSITION;
                float2 uv       : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv       : TEXCOORD0;
                float  power    : COLOR0;
                UNITY_FOG_COORDS(1)
                float4 vertex   : SV_POSITION;
            };

            sampler2D   _MainTex;
            float4      _MainTex_ST;
            float       _MainTexPower;
            float4      _Color;
            float       _Transparency;
            float       _MinDist;
            float       _MaxDist;
            float       _CenterX;
            float       _CenterZ;
            float       _MinAlpha;
            float       _Speed_U;
            float       _Speed_V;
            float       _UpperY;

            inline float3 worldSpaceCameraPos() {
                #ifdef USING_STEREO_MATRICES
                    return (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * 0.5;
                #else
                    return _WorldSpaceCameraPos;
                #endif
            }

            v2f vert(appdata v) {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = v.uv + float2(frac(_Time.x * _Speed_U), frac(_Time.x * _Speed_V));
                o.uv = TRANSFORM_TEX(uv, _MainTex);

                float3 ws_camera_pos = worldSpaceCameraPos();
                float distance = length(ws_camera_pos.xz - float2(_CenterX, _CenterZ));
                float alpha = pow(smoothstep(_MinDist, _MaxDist, distance), 2) * (1 - smoothstep(_UpperY, _UpperY + 1, ws_camera_pos.y));
                o.power = alpha * (1 - _MinAlpha) + _MinAlpha;

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 mainTex = tex2D(_MainTex, i.uv);
                // Texture Power
                mainTex.rgb = (mainTex.rgb - 1) * _MainTexPower + 1;

                // alpha 確定
                fixed alpha = mainTex.a * _Color.a * i.power;
                // ブレンド
                fixed4 color = fixed4(mainTex.rgb * _Color.rgb * saturate(alpha), _Transparency * i.power);

                UNITY_APPLY_FOG(i.fogCoord, color);
                return color;
            }

            ENDCG
        }
    }
}
