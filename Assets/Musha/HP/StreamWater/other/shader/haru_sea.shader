// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "haru_sea"
{
	Properties
	{
		[SingleLineTexture]_MainTex("MainTex", 2D) = "white" {}
		_normalmap("normalmap", 2D) = "white" {}
		[HDR]_MainColor("MainColor", Color) = (0.7688679,0.8877963,1,1)
		[HDR]_TopColor("TopColor", Color) = (0.5707992,0.6850951,0.9528302,1)
		_smoothness("smoothness", Range( 0 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_XY("X Y", Vector) = (0,1,0,0)
		_pand("pand", Vector) = (1,0,0,0)
		_pandd("pandd", Vector) = (-1,0,0,0)
		_hight("hight", Float) = 1
		_up("up", Vector) = (0,1,0,0)
		_speed("speed", Float) = 1
		_wabetile("wabe tile", Float) = 1
		_tessellationmin("tessellationmin", Float) = 0
		_tessellationmax("tessellationmax", Float) = 20
		_tessellation("tessellation", Float) = 20
		_tiling("tiling", Vector) = (1,1,0,0)
		_distance("distance", Float) = 0
		_distancepower("distance power", Float) = 0
		_normalstreng("normal streng", Range( 0 , 1)) = 0.5356805
		_normalspeed("normal speed", Float) = 1
		_normal2("normal 2", Float) = 1
		_normaltiling("normal tiling", Float) = 1
		_noiseScale("noiseScale", Float) = 5
		_foam("foam", 2D) = "white" {}
		_foamTile("foamTile", Float) = 1
		_Float0("Float 0", Float) = 10
		_foamTile10("foamTile10", Float) = 10
		_seaTile("seaTile", Float) = 1
		_refractamou("refractamou", Float) = 0
		_depth("depth", Float) = -4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform float3 _up;
		uniform float _hight;
		uniform float _speed;
		uniform float2 _XY;
		uniform float2 _tiling;
		uniform float _wabetile;
		uniform float _noiseScale;
		uniform sampler2D _normalmap;
		uniform float2 _pand;
		uniform float _normalspeed;
		uniform float _normaltiling;
		uniform float _normalstreng;
		uniform float2 _pandd;
		uniform float _normal2;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _MainColor;
		uniform float4 _TopColor;
		uniform sampler2D _foam;
		uniform float _Float0;
		uniform float _seaTile;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _refractamou;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _depth;
		uniform float _distance;
		uniform float _foamTile10;
		uniform float _foamTile;
		uniform float _distancepower;
		uniform float _Metallic;
		uniform float _smoothness;
		uniform float _tessellationmin;
		uniform float _tessellationmax;
		uniform float _tessellation;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _tessellationmin,_tessellationmax,_tessellation);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float temp_output_10_0 = ( _Time.y * _speed );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult15 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSp16 = appendResult15;
			float4 wavetileuv26 = ( ( WorldSp16 * float4( _tiling, 0.0 , 0.0 ) ) * _wabetile );
			float2 panner7 = ( temp_output_10_0 * _XY + wavetileuv26.xy);
			float simplePerlin2D6 = snoise( panner7*_noiseScale );
			simplePerlin2D6 = simplePerlin2D6*0.5 + 0.5;
			float temp_output_32_0 = ( simplePerlin2D6 + 0.0 );
			float3 wabehight42 = ( ( _up * _hight ) * temp_output_32_0 );
			v.vertex.xyz += wabehight42;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult15 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSp16 = appendResult15;
			float4 temp_output_66_0 = ( WorldSp16 * _normaltiling );
			float2 panner70 = ( 1.0 * _Time.y * ( _pand * _normalspeed ) + temp_output_66_0.xy);
			float2 panner71 = ( 1.0 * _Time.y * ( ( _normalspeed * 3.0 ) * _pandd ) + ( temp_output_66_0 * ( _normaltiling * _normal2 ) ).xy);
			float3 noemal80 = BlendNormals( UnpackScaleNormal( tex2D( _normalmap, panner70 ), _normalstreng ) , UnpackScaleNormal( tex2D( _normalmap, panner71 ), _normalstreng ) );
			o.Normal = noemal80;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 wavetileuv26 = ( ( WorldSp16 * float4( _tiling, 0.0 , 0.0 ) ) * _wabetile );
			float4 seafoam98 = tex2D( _foam, ( ( wavetileuv26 / _Float0 ) * _seaTile ).xy );
			float temp_output_10_0 = ( _Time.y * _speed );
			float2 panner7 = ( temp_output_10_0 * _XY + wavetileuv26.xy);
			float simplePerlin2D6 = snoise( panner7*_noiseScale );
			simplePerlin2D6 = simplePerlin2D6*0.5 + 0.5;
			float temp_output_32_0 = ( simplePerlin2D6 + 0.0 );
			float wabePattern39 = temp_output_32_0;
			float clampResult49 = clamp( wabePattern39 , 0.0 , 1.0 );
			float4 lerpResult47 = lerp( _MainColor , ( _TopColor * seafoam98 ) , clampResult49);
			float4 MainColor51 = ( tex2D( _MainTex, uv_MainTex ) * lerpResult47 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor108 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( (ase_grabScreenPosNorm).xyzw + float4( ( _refractamou * noemal80 ) , 0.0 ) ).xy);
			float4 clampResult109 = clamp( screenColor108 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 refraction110 = clampResult109;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth114 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth114 = abs( ( screenDepth114 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _depth ) );
			float clampResult115 = clamp( ( 1.0 - distanceDepth114 ) , 0.0 , 1.0 );
			float depth116 = clampResult115;
			float4 lerpResult117 = lerp( MainColor51 , refraction110 , depth116);
			o.Albedo = lerpResult117.rgb;
			float screenDepth53 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth53 = abs( ( screenDepth53 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _distance ) );
			float4 clampResult59 = clamp( ( ( ( 1.0 - distanceDepth53 ) + tex2D( _foam, ( ( wavetileuv26 / _foamTile10 ) * _foamTile ).xy ) ) * _distancepower ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 eg57 = clampResult59;
			o.Emission = eg57.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _smoothness;
			o.Alpha = ( _MainColor.a * _TopColor.a );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.WorldPosInputsNode;14;-2605.543,-846.171;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;15;-2334.994,-848.483;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-1943.923,-1373.686;Inherit;False;16;WorldSp;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1715.185,-1333.88;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1426.344,-1298.118;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1703.325,-1038.714;Inherit;False;Property;_wabetile;wabe tile;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;19;-1917.617,-1190.061;Inherit;False;Property;_tiling;tiling;17;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;9;-2658.779,546.3832;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;8;-2440.791,269.9168;Inherit;False;Property;_XY;X Y;7;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;28;-2022.197,545.8428;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;31;-2607.615,154.8542;Inherit;False;Property;_aaa;aaa;18;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-1401.776,437.355;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2263.728,168.9555;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-2429.937,546.7206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-2434.619,777.9309;Inherit;False;26;wavetileuv;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-2208.602,767.7674;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2635.448,759.3254;Inherit;False;Property;_speed;speed;12;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;24;-1872.171,-418.3157;Inherit;False;Property;_up;up;11;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;40;-1873.499,-108.4312;Inherit;False;Property;_hight;hight;10;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1678.595,-250.2265;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1392.351,-166.9143;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-1178.253,-170.4332;Inherit;False;wabehight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-2516.095,-89.66179;Inherit;False;26;wavetileuv;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-2121.126,-854.5677;Inherit;False;WorldSp;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-1750.114,-3045.176;Inherit;False;16;WorldSp;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1460.805,-3047.186;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;7;-2000.134,239.6989;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;63;135.3015,-2679.485;Inherit;True;Property;_nomalmap2;nomalmap;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;61;149.7453,-3076.275;Inherit;True;Property;_nomalmap1;nomalmap;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;71;-357.9797,-2500.323;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;70;-363.1133,-3132.771;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-1224.129,-2283.459;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-648.3197,-3078.839;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendNormalsNode;78;520.71,-2908.869;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;72;-933.3325,-3042.411;Inherit;False;Property;_pand;pand;8;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;67;-1725.162,-2830.488;Inherit;False;Property;_normaltiling;normal tiling;24;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-101.2273,-2876.506;Inherit;False;Property;_normalstreng;normal streng;21;0;Create;True;0;0;0;False;0;False;0.5356805;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;860.7996,-2928.011;Inherit;False;noemal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-582.2712,-2427.995;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-817.7037,-2721.768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-1451.898,-2317.332;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;73;-861.8828,-2400.238;Inherit;False;Property;_pandd;pandd;9;0;Create;True;0;0;0;False;0;False;-1,0;-1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;75;-1016.245,-2715.267;Inherit;False;Property;_normalspeed;normal speed;22;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-1784.363,-2315.105;Inherit;False;Property;_normal2;normal 2;23;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-1136.931,438.8193;Inherit;False;wabePattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;29;-1665.211,482.2603;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;4.88;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-1166.634,-1355.434;Inherit;False;wavetileuv;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;84;-4082.74,-1931.337;Inherit;True;Property;_foam;foam;26;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.OneMinusNode;54;-4143.674,-2552.163;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-4603.674,-2532.163;Inherit;False;Property;_distance;distance;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;53;-4408.674,-2552.163;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-3437.472,-1987.885;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-3414.457,-2555.843;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-2900.662,-2557.537;Inherit;False;eg;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-3675.332,-2539.289;Inherit;False;Property;_distancepower;distance power;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;59;-3165.649,-2540.715;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-4059.961,-1702.799;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-4682.44,-1737.219;Inherit;False;26;wavetileuv;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;89;-4339.675,-1714.981;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-4665.467,-1214.371;Inherit;False;26;wavetileuv;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;95;-4322.702,-1192.133;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;85;-3844.479,-1924.156;Inherit;True;Property;_TextureSample0;Texture Sample 0;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;97;-3800.456,-1174.586;Inherit;True;Property;_TextureSample1;Texture Sample 0;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-4064.198,-1168.383;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-3420.449,-1182.042;Inherit;False;seafoam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;2;-536.1286,-1433.833;Inherit;False;Property;_MainColor;MainColor;3;1;[HDR];Create;True;0;0;0;False;0;False;0.7688679,0.8877963,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;46;-568.3812,-1254.566;Inherit;False;Property;_TopColor;TopColor;4;1;[HDR];Create;True;0;0;0;False;0;False;0.5707992,0.6850951,0.9528302,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;48;-660.5654,-854.0757;Inherit;False;39;wabePattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-562.4974,-1056.559;Inherit;False;98;seafoam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-4677.318,-1530.434;Inherit;False;Property;_foamTile10;foamTile10;29;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-4660.345,-1007.586;Inherit;False;Property;_Float0;Float 0;28;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-4310.803,-946.0737;Inherit;False;Property;_seaTile;seaTile;30;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-4327.776,-1468.922;Inherit;False;Property;_foamTile;foamTile;27;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;102;-4546.181,-254.7904;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;103;-4252.211,-224.9812;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-4739.913,-104.5519;Inherit;False;Property;_refractamou;refractamou;31;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-4537.913,59.44806;Inherit;False;80;noemal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-4312.913,-27.55194;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-3975.913,-124.5519;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;108;-3765.584,-132.8061;Inherit;False;Global;_GrabScreen0;Grab Screen 0;27;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-3297.584,-128.906;Inherit;False;refraction;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;109;-3548.482,-125.006;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;114;-4093.447,479.9955;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-4362.567,468.1592;Inherit;False;Property;_depth;depth;32;0;Create;True;0;0;0;False;0;False;-4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-3285.447,505.9955;Inherit;False;depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;115;-3570.447,494.9955;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;118;-3806.714,499.1545;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;49;-376.2485,-862.8199;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;haru_sea;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;2;15;10;25;False;0.5;False;2;5;False;;10;False;;2;5;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;2;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-417.0148,84.62939;Inherit;False;57;eg;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;-490.3217,-79.10196;Inherit;False;80;noemal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceBasedTessNode;120;-210.1947,572.265;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-544.7898,527.2837;Inherit;False;Property;_tessellation;tessellation;16;0;Create;True;0;0;0;False;0;False;20;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-500.1947,762.265;Inherit;False;Property;_tessellationmin;tessellationmin;14;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-492.1947,966.265;Inherit;False;Property;_tessellationmax;tessellationmax;15;0;Create;True;0;0;0;False;0;False;20;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;64;-1480.041,-2736.34;Inherit;True;Property;_normalmap;normalmap;1;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.NoiseGeneratorNode;6;-1722.555,223.1064;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;4.88;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-1928.956,450.628;Inherit;False;Property;_noiseScale;noiseScale;25;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-716.1007,177.437;Inherit;False;Property;_Metallic;Metallic;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-694.3848,394.7259;Inherit;False;Property;_smoothness;smoothness;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-277.7449,363.153;Inherit;False;42;wabehight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-15.10886,-835.0547;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;117;-331.297,-475.304;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-674.5321,-196.7994;Inherit;False;116;depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-690.2364,-385.7772;Inherit;False;110;refraction;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-696.3836,-585.2286;Inherit;False;51;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;47;523.8836,-1394.298;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;870.7223,-1598.663;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;212.4535,-1272.856;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;205.1949,-1061.28;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;127;-231.4639,-1712.728;Inherit;True;Property;_MainTex;MainTex;0;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;537.627,-1638.544;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;15;0;14;1
WireConnection;15;1;14;3
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;20;0;18;0
WireConnection;20;1;22;0
WireConnection;28;0;38;0
WireConnection;28;2;8;0
WireConnection;28;1;10;0
WireConnection;32;0;6;0
WireConnection;30;0;27;0
WireConnection;30;1;31;0
WireConnection;10;0;9;0
WireConnection;10;1;12;0
WireConnection;38;0;37;0
WireConnection;25;0;24;0
WireConnection;25;1;40;0
WireConnection;41;0;25;0
WireConnection;41;1;32;0
WireConnection;42;0;41;0
WireConnection;16;0;15;0
WireConnection;66;0;65;0
WireConnection;66;1;67;0
WireConnection;7;0;27;0
WireConnection;7;2;8;0
WireConnection;7;1;10;0
WireConnection;63;0;64;0
WireConnection;63;1;71;0
WireConnection;63;5;79;0
WireConnection;61;0;64;0
WireConnection;61;1;70;0
WireConnection;61;5;79;0
WireConnection;71;0;69;0
WireConnection;71;2;77;0
WireConnection;70;0;66;0
WireConnection;70;2;74;0
WireConnection;69;0;66;0
WireConnection;69;1;68;0
WireConnection;74;0;72;0
WireConnection;74;1;75;0
WireConnection;78;0;61;0
WireConnection;78;1;63;0
WireConnection;80;0;78;0
WireConnection;77;0;76;0
WireConnection;77;1;73;0
WireConnection;76;0;75;0
WireConnection;68;0;67;0
WireConnection;68;1;83;0
WireConnection;39;0;32;0
WireConnection;29;0;28;0
WireConnection;26;0;20;0
WireConnection;54;0;53;0
WireConnection;53;0;52;0
WireConnection;91;0;54;0
WireConnection;91;1;85;0
WireConnection;55;0;91;0
WireConnection;55;1;56;0
WireConnection;57;0;59;0
WireConnection;59;0;55;0
WireConnection;87;0;89;0
WireConnection;87;1;88;0
WireConnection;89;0;86;0
WireConnection;89;1;90;0
WireConnection;95;0;93;0
WireConnection;95;1;94;0
WireConnection;85;0;84;0
WireConnection;85;1;87;0
WireConnection;97;0;84;0
WireConnection;97;1;92;0
WireConnection;92;0;95;0
WireConnection;92;1;96;0
WireConnection;98;0;97;0
WireConnection;103;0;102;0
WireConnection;106;0;104;0
WireConnection;106;1;105;0
WireConnection;107;0;103;0
WireConnection;107;1;106;0
WireConnection;108;0;107;0
WireConnection;110;0;109;0
WireConnection;109;0;108;0
WireConnection;114;0;112;0
WireConnection;116;0;115;0
WireConnection;115;0;118;0
WireConnection;118;0;114;0
WireConnection;49;0;48;0
WireConnection;0;0;117;0
WireConnection;0;1;81;0
WireConnection;0;2;58;0
WireConnection;0;3;125;0
WireConnection;0;4;44;0
WireConnection;0;9;124;0
WireConnection;0;11;43;0
WireConnection;0;14;120;0
WireConnection;120;0;23;0
WireConnection;120;1;121;0
WireConnection;120;2;122;0
WireConnection;6;0;7;0
WireConnection;6;1;126;0
WireConnection;124;0;2;4
WireConnection;124;1;46;4
WireConnection;117;0;50;0
WireConnection;117;1;111;0
WireConnection;117;2;123;0
WireConnection;47;0;2;0
WireConnection;47;1;101;0
WireConnection;47;2;49;0
WireConnection;51;0;128;0
WireConnection;99;0;46;0
WireConnection;99;1;100;0
WireConnection;101;0;46;0
WireConnection;101;1;100;0
WireConnection;128;0;127;0
WireConnection;128;1;47;0
ASEEND*/
//CHKSM=DF90AAFBCBD5513650EC6B6F43BC1E389761FBF3