// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Custom/HeavensShader" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Resolution("Cloud Resolution", Float) = 60.0
		_Height("Cloud Height", Float) = 1.0
		_SpeedX("X Speed", Float) = 1.0
		_SpeedY("Y Speed", Float) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;

		float _Resolution;
		float _Height;
		float _SpeedX;
		float _SpeedY;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		fixed2 random2(fixed2 st)
		{
			st = fixed2(
				dot(st, fixed2(127.1f, 311.7f)),
				dot(st, fixed2(269.5f, 183.3f))
			);
			return -1.0f + 2.0f * frac(sin(st) * 43758.5453123f);
		}

		float perlinNoise(fixed2 st)
		{
			fixed2 p = floor(st);
			fixed2 f = frac(st);
			fixed2 u = f * f * (3.0f - 2.0f * f);

			float v00 = random2(p + fixed2(0.0f, 0.0f));
			float v10 = random2(p + fixed2(1.0f, 0.0f));
			float v01 = random2(p + fixed2(0.0f, 1.0f));
			float v11 = random2(p + fixed2(1.0f, 1.0f));

			return lerp(
				lerp(dot(v00, f - fixed2(0.0f, 0.0f)), dot(v10, f - fixed2(1.0f, 0.0f)), u.x),
				lerp(dot(v01, f - fixed2(0.0f, 1.0f)), dot(v11, f - fixed2(1.0f, 1.0f)), u.x),
				u.y)
				+ 0.5f;
		}

		float fBm(fixed2 st)
		{
			float f = 0.0f;
			fixed2 q = st;

			f += 0.5000f * perlinNoise(q);
			q *= 2.01f;
			f += 0.2500f * perlinNoise(q);
			q *= 2.02f;
			f += 0.1250f * perlinNoise(q);
			q *= 2.03f;
			f += 0.0625f * perlinNoise(q);
			q *= 2.04f;

			return f;
		}

		struct appdata {
			float4 texcoord : TEXCOORD0;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			float2 uv = float2(v.texcoord.x, v.texcoord.y);
			uv.x += _SpeedX * _Time;
			uv.y += _SpeedY * _Time;
			float c = _Height * fBm(uv * _Resolution);

			v.vertex.xyz = float3(v.vertex.x, v.vertex.y + c, v.vertex.z);
		}

		void surf (Input IN, inout SurfaceOutput o) {
			float2 uv = IN.uv_MainTex;
			uv.x += _SpeedX * _Time;
			uv.y += _SpeedY * _Time;
			float c = fBm(uv * _Resolution);
			o.Albedo = fixed4(c, c, c, 1.0f);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
