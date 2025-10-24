Shader "Noriben/nLightShaft"
{
    Properties
    {
        _MainCol ("Main col", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Distance ("Distance", float) = 1
        _DistancePow ("DistancePow", float) = 1
        _ScrollSpeed ("ScrollSpeed", float) = .1
        _Brightness ("Brightness", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        LOD 100
        Cull Off
        Blend SrcAlpha One
        ZWrite off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            //GPU instancing
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD2;
                float3 worldCenterPos : TEXCOORD3;
                fixed4 color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Distance;
            float _DistancePow;
            float _ScrollSpeed;
            float4 _MainCol;
            float _Brightness;

            v2f vert (appdata v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldCenterPos = mul(unity_ObjectToWorld, float4(1,1,0,1)).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float2 uv = frac(i.uv);
                float4 tex = tex2D(_MainTex, float2( (i.worldCenterPos.x + i.worldCenterPos.z) + _Time.x * _ScrollSpeed, uv.y + (i.worldCenterPos.x + i.worldCenterPos.z) ));

                float distance = length(_WorldSpaceCameraPos - i.worldPos);
                float disCol = lerp(0, 1, pow(saturate(distance / _Distance), _DistancePow));
                
                //gradations
                float gradX = smoothstep(0, .2, uv.y) * (1.-smoothstep(.8, 1, uv.y));
                float gradY = uv.x * (1.-smoothstep(0.5, 1., uv.x));
                float grad = gradX * gradY;


                tex = tex * disCol * _MainCol * grad * _Brightness * i.color;
                tex = saturate(tex);
                fixed4 col = tex;

                //col = float4(i.worldCenterPos.y,i.worldCenterPos.y,i.worldCenterPos.y,1);                
                //col = float4(gradY,gradY,gradY, 1);
                //col = float4(gradX,gradX,gradX,1);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
