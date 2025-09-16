// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "uniuni/WaterBottomLight"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_MetallicSmoothness("MetallicSmoothness", 2D) = "white" {}
		_Metaric("Metaric", Range( 0 , 1)) = 0
		_Smooth("Smooth", Range( 0 , 1)) = 1
		_Occlusion("Occlusion", 2D) = "white" {}
		_Emission("Emission", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		[Normal]_Normal("Normal", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 1
		[NoScaleOffset]_Gradation("Gradation", 2D) = "white" {}
		_HightOffset("HightOffset", Float) = 0
		_Attenuation("Attenuation", Float) = 0.1
		_Scattering("Scattering", Range( 0 , 1)) = 0.1
		[NoScaleOffset]_Caustics("Caustics", 2D) = "black" {}
		_CausticsDepth("CausticsDepth", Float) = 0.5
		_CausticsScale("CausticsScale", Float) = 0.2
		_CausticsSpeed("CausticsSpeed", Float) = 0.2
		_CausticsBrightness("CausticsBrightness", Float) = 2
		_CausticsDistanceFade("CausticsDistanceFade", Float) = 20
		_Wet("Wet", Range( 1 , 0)) = 0
		_WetAreaLevel("WetAreaLevel", Float) = 1
		_WetAreaSharpness("WetAreaSharpness", Float) = 1
		_LightVector("LightVector", Vector) = (0,0,0,0)
		[Toggle]_HorizonCutOut("HorizonCutOut", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		AlphaToMask On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float4 vertexColor : COLOR;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float eyeDepth;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _HorizonCutOut;
		uniform float _HightOffset;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float _WetAreaLevel;
		uniform float _WetAreaSharpness;
		uniform float _Wet;
		uniform float4 _Color;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _NormalScale;
		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform float4 _EmissionColor;
		uniform sampler2D _MetallicSmoothness;
		uniform float4 _MetallicSmoothness_ST;
		uniform float _Metaric;
		uniform float _Smooth;
		uniform sampler2D _Occlusion;
		uniform float4 _Occlusion_ST;
		uniform sampler2D _Gradation;
		uniform float _Attenuation;
		uniform float _Scattering;
		uniform sampler2D _Caustics;
		uniform float3 _LightVector;
		uniform float _CausticsScale;
		uniform float _CausticsSpeed;
		uniform float _CausticsDepth;
		uniform float _CausticsBrightness;
		uniform float _CausticsDistanceFade;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float CameraWaterHight238 = ( _WorldSpaceCameraPos.y - _HightOffset );
			float CameraSide314 = ceil( saturate( CameraWaterHight238 ) );
			float lerpResult313 = lerp( 1.0 , ( ase_worldViewDir.y + i.vertexColor.r ) , CameraSide314);
			float temp_output_1_0_g1 = lerpResult313;
			SurfaceOutputStandard s88 = (SurfaceOutputStandard ) 0;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float temp_output_74_0 = ( _HightOffset - ase_worldPos.y );
			float HightFromeWater266 = temp_output_74_0;
			s88.Albedo = ( tex2D( _Albedo, uv_Albedo ) * saturate( ( ( saturate( -( HightFromeWater266 + _WetAreaLevel ) ) * _WetAreaSharpness ) + _Wet ) ) * _Color ).rgb;
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			s88.Normal = WorldNormalVector( i , UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _NormalScale ) );
			float2 uv_Emission = i.uv_texcoord * _Emission_ST.xy + _Emission_ST.zw;
			s88.Emission = ( tex2D( _Emission, uv_Emission ) * _EmissionColor ).rgb;
			float2 uv_MetallicSmoothness = i.uv_texcoord * _MetallicSmoothness_ST.xy + _MetallicSmoothness_ST.zw;
			float4 tex2DNode120 = tex2D( _MetallicSmoothness, uv_MetallicSmoothness );
			s88.Metallic = ( tex2DNode120.r * _Metaric );
			s88.Smoothness = ( tex2DNode120.a * _Smooth );
			float2 uv_Occlusion = i.uv_texcoord * _Occlusion_ST.xy + _Occlusion_ST.zw;
			s88.Occlusion = tex2D( _Occlusion, uv_Occlusion ).g;

			data.light = gi.light;

			UnityGI gi88 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g88 = UnityGlossyEnvironmentSetup( s88.Smoothness, data.worldViewDir, s88.Normal, float3(0,0,0));
			gi88 = UnityGlobalIllumination( data, s88.Occlusion, s88.Normal, g88 );
			#endif

			float3 surfResult88 = LightingStandard ( s88, viewDir, gi88 ).rgb;
			surfResult88 += s88.Emission;

			#ifdef UNITY_PASS_FORWARDADD//88
			surfResult88 -= s88.Emission;
			#endif//88
			float clampResult76 = clamp( temp_output_74_0 , 0.0 , temp_output_74_0 );
			float WaterDepth107 = clampResult76;
			float dotResult69 = dot( ase_worldViewDir , float3(0,1,0) );
			float clampResult77 = clamp( dotResult69 , 0.01 , 1.0 );
			float lerpResult245 = lerp( distance( _WorldSpaceCameraPos , ase_worldPos ) , ( WaterDepth107 / clampResult77 ) , CameraSide314);
			float VertecColorG247 = i.vertexColor.g;
			float temp_output_233_0 = ( 1.0 - i.vertexColor.r );
			float lerpResult284 = lerp( saturate( ( ( WaterDepth107 + lerpResult245 ) * _Attenuation * VertecColorG247 ) ) , 1.0 , temp_output_233_0);
			float2 appendResult118 = (float2(lerpResult284 , 0.0));
			float4 tex2DNode115 = tex2D( _Gradation, saturate( appendResult118 ) );
			float clampResult113 = clamp( lerpResult245 , 0.0 , 1.0 );
			float Distance320 = distance( _WorldSpaceCameraPos , ase_worldPos );
			float lerpResult318 = lerp( Distance320 , WaterDepth107 , CameraSide314);
			float lerpResult285 = lerp( ( _Scattering * clampResult113 * lerpResult318 * VertecColorG247 ) , 1.0 , temp_output_233_0);
			float2 appendResult116 = (float2(lerpResult285 , 1.0));
			float3 normalizeResult299 = normalize( _LightVector );
			float3 _UP = float3(0,1,0);
			float dotResult300 = dot( normalizeResult299 , _UP );
			float3 rotatedValue293 = RotateAroundAxis( float3( 0,0,0 ), ase_worldPos, normalize( cross( normalizeResult299 , _UP ) ), acos( dotResult300 ) );
			float3 break302 = rotatedValue293;
			float2 appendResult135 = (float2(break302.x , break302.z));
			float2 temp_output_137_0 = ( appendResult135 * _CausticsScale );
			float temp_output_159_0 = ( _Time.y * _CausticsSpeed );
			float temp_output_204_0 = ( temp_output_159_0 * 0.701 );
			float temp_output_205_0 = ( temp_output_159_0 * 0.997 );
			float2 appendResult153 = (float2(temp_output_204_0 , temp_output_205_0));
			float2 appendResult190 = (float2(-temp_output_204_0 , 0.0));
			float2 appendResult207 = (float2(break302.z , break302.x));
			float2 temp_output_208_0 = ( appendResult207 * _CausticsScale );
			float temp_output_211_0 = ( temp_output_159_0 * 0.881 );
			float2 appendResult194 = (float2(temp_output_211_0 , -temp_output_205_0));
			float2 appendResult195 = (float2(-temp_output_211_0 , 0.0));
			float cameraDepthFade226 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 LightVrctor295 = normalizeResult299;
			float dotResult290 = dot( -ase_normWorldNormal , LightVrctor295 );
			c.rgb = ( ( float4( surfResult88 , 0.0 ) * tex2DNode115 ) + tex2D( _Gradation, saturate( appendResult116 ) ) + saturate( ( tex2DNode115 * abs( sin( ( ( min( tex2D( _Caustics, ( temp_output_137_0 + appendResult153 ) ) , tex2D( _Caustics, ( temp_output_137_0 + appendResult190 ) ) ) + min( tex2D( _Caustics, ( temp_output_208_0 + appendResult194 ) ) , tex2D( _Caustics, ( temp_output_208_0 + appendResult195 ) ) ) ) * ( 4.0 * UNITY_PI ) ) ) ) * saturate( WaterDepth107 ) * ( 1.0 - saturate( ( WaterDepth107 * _CausticsDepth ) ) ) * _CausticsBrightness * VertecColorG247 * ( 1.0 - saturate( ( cameraDepthFade226 / _CausticsDistanceFade ) ) ) * saturate( dotResult290 ) ) ) ).rgb;
			c.a = (( _HorizonCutOut )?( saturate( ( ( ( temp_output_1_0_g1 - 0.0 ) / max( fwidth( temp_output_1_0_g1 ) , 0.0001 ) ) + 0.5 ) ) ):( 1.0 ));
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.z = customInputData.eyeDepth;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.eyeDepth = IN.customPack1.z;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18712
0;-1066;1920;1044;-701.9874;492.0068;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;110;-1232,176;Inherit;False;762.1432;306.0001;WaterDepth;7;107;76;74;73;75;266;316;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;289;-2439,700;Inherit;False;Property;_LightVector;LightVector;24;0;Create;True;0;0;0;False;0;False;0,0,0;0.03,-0.64,0.87;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;75;-1168,224;Inherit;False;Property;_HightOffset;HightOffset;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;235;-1248,32;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;73;-1184,304;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;299;-2184.756,709.9413;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;297;-2375,844;Inherit;False;Constant;_UP;UP;23;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;237;-992,80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;111;-1248,496;Inherit;False;795.0001;351.376;BottomDistance;7;72;77;69;112;67;68;246;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;-992,272;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;300;-2018.265,950.1992;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;238;-864,80;Inherit;False;CameraWaterHight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;311;-624,80;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CrossProductOpNode;298;-1961.513,776.0911;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;219;-1621.9,1424.5;Inherit;False;Property;_CausticsSpeed;CausticsSpeed;18;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;68;-1200,688;Inherit;False;Constant;_UPvector;UPvector;4;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;67;-1200,544;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;149;-1585.893,1332.448;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;76;-832,272;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ACosOpNode;301;-1869.265,947.1992;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;134;-2034.666,1204.468;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotateAboutAxisNode;293;-1728.61,907.9421;Inherit;False;True;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;275;-816,-1936;Inherit;False;1716.634;1701.818;Comment;25;122;121;120;90;91;267;125;88;119;127;281;2;126;279;129;283;270;273;274;271;282;268;269;308;322;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;266;-832,400;Inherit;False;HightFromeWater;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-1386.149,1339.757;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;69;-960,608;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-534,264;Inherit;False;WaterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-1008,704;Inherit;False;Constant;_UnderRimit;UnderRimit;8;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;312;-480,80;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;269;-656,-1616;Inherit;False;Property;_WetAreaLevel;WetAreaLevel;22;0;Create;True;0;0;0;False;0;False;1;0.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;77;-832,608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;-880,528;Inherit;False;107;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;267;-704,-1696;Inherit;False;266;HightFromeWater;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;302;-1240.217,1057.11;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;-1176.11,1418.549;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.997;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-1163.11,1326.549;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.701;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;-1190.85,1614.903;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.881;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;240;-1280,928;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;314;-352.3801,176.4169;Inherit;False;CameraSide;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;206;-932.1099,1435.549;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;207;-894.1099,1196.549;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;209;-968.9568,1640.945;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;218;-1236.156,1230.259;Inherit;False;Property;_CausticsScale;CausticsScale;17;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;268;-480,-1680;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;317;-562.4376,843.8181;Inherit;False;314;CameraSide;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;210;-951.9568,1548.945;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-901.7095,1084.027;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;241;-940.1982,969.6997;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;72;-656,576;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-746.0871,1082.497;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0.2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;251;-336,48;Inherit;False;364;116;Ignore;1;247;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;194;-759,1533;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;153;-759,1341;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;232;-627,-105;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;245;-320,608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-736,1200;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0.2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;195;-759,1629;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;190;-759,1437;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;282;-352,-1648;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;166;-327.0465,1332.839;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;247;-256,80;Inherit;False;VertecColorG;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-128,240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;189;-343.6633,1454.861;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;188;-336.6633,1196.861;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;150;-330.893,1075.448;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;319;-935.694,-31.60443;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-176,336;Inherit;False;Property;_Attenuation;Attenuation;13;0;Create;True;0;0;0;False;0;False;0.1;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;271;-304,-1584;Inherit;False;Property;_WetAreaSharpness;WetAreaSharpness;23;0;Create;True;0;0;0;False;0;False;1;5.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;274;-224,-1648;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;-240,-1504;Inherit;False;Property;_Wet;Wet;21;0;Create;True;0;0;0;False;0;False;0;0.712;1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;133;-112.84,1129.903;Inherit;True;Property;_TextureSample1;Texture Sample 1;15;0;Create;True;0;0;0;False;0;False;-1;None;9470468fda72f4773a90a0306decbf0f;True;0;False;white;Auto;False;Instance;132;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;250;-336,-96;Inherit;False;364;141;FakeDeepArea;1;233;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;320;-797.694,-37.60443;Inherit;False;Distance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;270;-80,-1648;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;132;-112.84,937.9026;Inherit;True;Property;_Caustics;Caustics;15;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;95dc347de69588f499382adc8206af9a;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;165;-112.84,1513.903;Inherit;True;Property;_TextureSample3;Texture Sample 3;15;0;Create;True;0;0;0;False;0;False;-1;None;9470468fda72f4773a90a0306decbf0f;True;0;False;white;Auto;False;Instance;132;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;164;-112.84,1321.903;Inherit;True;Property;_TextureSample2;Texture Sample 2;15;0;Create;True;0;0;0;False;0;False;-1;None;9470468fda72f4773a90a0306decbf0f;True;0;False;white;Auto;False;Instance;132;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;0,240;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-257,789;Inherit;False;107;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;283;64,-1648;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;162;202.4749,1044.151;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;258;144,240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;163;223.4616,1412.617;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;321;-238.3499,721.7285;Inherit;False;320;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;108;-179.2122,440.5268;Inherit;False;815.6428;367.3997;Scattering;5;104;105;113;116;285;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;233;-288,-48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-1672.582,787.3427;Inherit;False;LightVrctor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;126;64,-1264;Inherit;True;Property;_Emission;Emission;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CameraDepthFade;226;384,1472;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;48,-1840;Inherit;True;Property;_Albedo;Albedo;1;0;Create;True;0;0;0;False;0;False;-1;None;9470468fda72f4773a90a0306decbf0f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;148;256,944;Inherit;False;Property;_CausticsDepth;CausticsDepth;16;0;Create;True;0;0;0;False;0;False;0.5;0.53;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;32,-688;Inherit;False;Property;_Metaric;Metaric;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;284;288,240;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-99.63379,-1363.373;Inherit;False;Property;_NormalScale;NormalScale;10;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;129;144,-1072;Inherit;False;Property;_EmissionColor;EmissionColor;8;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;91;32,-608;Inherit;False;Property;_Smooth;Smooth;5;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;223;411,1750;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;279;192,-1648;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;230;384,1584;Inherit;False;Property;_CausticsDistanceFade;CausticsDistanceFade;20;0;Create;True;0;0;0;False;0;False;20;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;120;32,-880;Inherit;True;Property;_MetallicSmoothness;MetallicSmoothness;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;105;-160,528;Inherit;False;Property;_Scattering;Scattering;14;0;Create;True;0;0;0;False;0;False;0.1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;248;-125.8973,863.4474;Inherit;False;247;VertecColorG;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;318;-28.88898,727.9118;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;308;143.1211,-1562.364;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;179;318.6664,1329.463;Inherit;False;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;168;374.9534,1222.839;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;240,880;Inherit;False;107;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;113;-80,608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;292;601.1604,1800.386;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;119;240,-1472;Inherit;True;Property;_Normal;Normal;9;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;384,-720;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;118;448,240;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;160,640;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;231;624,1472;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;384,-816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;384,-1744;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;125;240,-512;Inherit;True;Property;_Occlusion;Occlusion;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;505.6664,1222.463;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;384,-1088;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;400,1904;Inherit;False;295;LightVrctor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;464,928;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;222;608,944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;260;1152,-128;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;177;649,1226;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;254;1152,-256;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;228;736,1472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;88;672,-1136;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;285;320,640;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;290;752,1840;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;130;576,240;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;229;864,1472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;115;720,208;Inherit;True;Property;_Gradation;Gradation;11;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;188bb68238e77dc4fa6a239e971a8904;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;315;1239.206,57.18509;Inherit;False;314;CameraSide;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;276;944.3614,-807.0688;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;180;777,1226;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;172;686.3506,1162.724;Inherit;False;Property;_CausticsBrightness;CausticsBrightness;19;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;688,1312;Inherit;False;247;VertecColorG;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;173;752,880;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;224;880,1840;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;220;752,944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;263;1344,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;116;496,640;Inherit;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;1136,1152;Inherit;False;8;8;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;131;656,640;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;277;1037.771,120.8503;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;313;1504,-80;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;117;800,608;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;115;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;138;1280,1152;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;307;1648,-80;Inherit;False;SharpAlpha;-1;;1;36b0460b52d96d04882ceb50e9b42822;0;2;1;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;1408,192;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;323;1807.718,190.1714;Inherit;False;Property;_HorizonCutOut;HorizonCutOut;26;0;Create;True;0;0;0;False;0;False;0;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;1600,304;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FractNode;304;-1353.269,1152.231;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-2063.297,1107.11;Inherit;False;Property;_test;test;25;0;Create;True;0;0;0;False;0;False;0;0.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;305;-1569.826,1192.567;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;316;-683.7136,254.8164;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2114.89,104.7325;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;uniuni/WaterBottomLight;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;299;0;289;0
WireConnection;237;0;235;2
WireConnection;237;1;75;0
WireConnection;74;0;75;0
WireConnection;74;1;73;2
WireConnection;300;0;299;0
WireConnection;300;1;297;0
WireConnection;238;0;237;0
WireConnection;311;0;238;0
WireConnection;298;0;299;0
WireConnection;298;1;297;0
WireConnection;76;0;74;0
WireConnection;76;2;74;0
WireConnection;301;0;300;0
WireConnection;293;0;298;0
WireConnection;293;1;301;0
WireConnection;293;3;134;0
WireConnection;266;0;74;0
WireConnection;159;0;149;0
WireConnection;159;1;219;0
WireConnection;69;0;67;0
WireConnection;69;1;68;0
WireConnection;107;0;76;0
WireConnection;312;0;311;0
WireConnection;77;0;69;0
WireConnection;77;1;112;0
WireConnection;302;0;293;0
WireConnection;205;0;159;0
WireConnection;204;0;159;0
WireConnection;211;0;159;0
WireConnection;314;0;312;0
WireConnection;206;0;204;0
WireConnection;207;0;302;2
WireConnection;207;1;302;0
WireConnection;209;0;211;0
WireConnection;268;0;267;0
WireConnection;268;1;269;0
WireConnection;210;0;205;0
WireConnection;135;0;302;0
WireConnection;135;1;302;2
WireConnection;241;0;240;0
WireConnection;241;1;134;0
WireConnection;72;0;246;0
WireConnection;72;1;77;0
WireConnection;137;0;135;0
WireConnection;137;1;218;0
WireConnection;194;0;211;0
WireConnection;194;1;210;0
WireConnection;153;0;204;0
WireConnection;153;1;205;0
WireConnection;245;0;241;0
WireConnection;245;1;72;0
WireConnection;245;2;317;0
WireConnection;208;0;207;0
WireConnection;208;1;218;0
WireConnection;195;0;209;0
WireConnection;190;0;206;0
WireConnection;282;0;268;0
WireConnection;166;0;208;0
WireConnection;166;1;194;0
WireConnection;247;0;232;2
WireConnection;79;0;107;0
WireConnection;79;1;245;0
WireConnection;189;0;208;0
WireConnection;189;1;195;0
WireConnection;188;0;137;0
WireConnection;188;1;190;0
WireConnection;150;0;137;0
WireConnection;150;1;153;0
WireConnection;319;0;235;0
WireConnection;319;1;73;0
WireConnection;274;0;282;0
WireConnection;133;1;188;0
WireConnection;320;0;319;0
WireConnection;270;0;274;0
WireConnection;270;1;271;0
WireConnection;132;1;150;0
WireConnection;165;1;189;0
WireConnection;164;1;166;0
WireConnection;13;0;79;0
WireConnection;13;1;78;0
WireConnection;13;2;247;0
WireConnection;283;0;270;0
WireConnection;283;1;273;0
WireConnection;162;0;132;0
WireConnection;162;1;133;0
WireConnection;258;0;13;0
WireConnection;163;0;164;0
WireConnection;163;1;165;0
WireConnection;233;0;232;1
WireConnection;295;0;299;0
WireConnection;284;0;258;0
WireConnection;284;2;233;0
WireConnection;279;0;283;0
WireConnection;318;0;321;0
WireConnection;318;1;114;0
WireConnection;318;2;317;0
WireConnection;168;0;162;0
WireConnection;168;1;163;0
WireConnection;113;0;245;0
WireConnection;292;0;223;0
WireConnection;119;5;322;0
WireConnection;122;0;120;4
WireConnection;122;1;91;0
WireConnection;118;0;284;0
WireConnection;104;0;105;0
WireConnection;104;1;113;0
WireConnection;104;2;318;0
WireConnection;104;3;248;0
WireConnection;231;0;226;0
WireConnection;231;1;230;0
WireConnection;121;0;120;1
WireConnection;121;1;90;0
WireConnection;281;0;2;0
WireConnection;281;1;279;0
WireConnection;281;2;308;0
WireConnection;178;0;168;0
WireConnection;178;1;179;0
WireConnection;127;0;126;0
WireConnection;127;1;129;0
WireConnection;221;0;143;0
WireConnection;221;1;148;0
WireConnection;222;0;221;0
WireConnection;177;0;178;0
WireConnection;228;0;231;0
WireConnection;88;0;281;0
WireConnection;88;1;119;0
WireConnection;88;2;127;0
WireConnection;88;3;121;0
WireConnection;88;4;122;0
WireConnection;88;5;125;2
WireConnection;285;0;104;0
WireConnection;285;2;233;0
WireConnection;290;0;292;0
WireConnection;290;1;296;0
WireConnection;130;0;118;0
WireConnection;229;0;228;0
WireConnection;115;1;130;0
WireConnection;276;0;88;0
WireConnection;180;0;177;0
WireConnection;173;0;143;0
WireConnection;224;0;290;0
WireConnection;220;0;222;0
WireConnection;263;0;254;2
WireConnection;263;1;260;1
WireConnection;116;0;285;0
WireConnection;136;0;115;0
WireConnection;136;1;180;0
WireConnection;136;2;173;0
WireConnection;136;3;220;0
WireConnection;136;4;172;0
WireConnection;136;5;249;0
WireConnection;136;6;229;0
WireConnection;136;7;224;0
WireConnection;131;0;116;0
WireConnection;277;0;276;0
WireConnection;313;1;263;0
WireConnection;313;2;315;0
WireConnection;117;1;131;0
WireConnection;138;0;136;0
WireConnection;307;1;313;0
WireConnection;12;0;277;0
WireConnection;12;1;115;0
WireConnection;323;1;307;0
WireConnection;84;0;12;0
WireConnection;84;1;117;0
WireConnection;84;2;138;0
WireConnection;304;0;305;0
WireConnection;305;0;293;0
WireConnection;316;0;76;0
WireConnection;0;9;323;0
WireConnection;0;13;84;0
ASEEND*/
//CHKSM=D37FD386F68A0056DE84DF5DEC2CBCE86F8D4B59