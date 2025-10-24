// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vket/Environment/SimpleWaterTriplanar"
{
	Properties
	{
		_WaterColor("WaterColor", Color) = (1,1,1,0)
		_Tilling("Tilling", Float) = 1
		[NoScaleOffset][Normal][SingleLineTexture]_Normal("Normal", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 1
		_Metallic("Metallic", Range( 0 , 1)) = 0.9
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_BaseReflection("BaseReflection", Range( 0 , 1)) = 0.05
		_ScrollU("ScrollU", Float) = 0.05
		_ScrollY("ScrollY", Float) = 0.06123
		_Refraction("Refraction", Float) = 0.5
		_OpacityNoise("OpacityNoise", Float) = 10
		_FallSpeed("FallSpeed", Float) = 3
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+100" "IgnoreProjector" = "True" }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
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
			float4 vertexColor : COLOR;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
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

		uniform sampler2D _Normal;
		uniform float _Tilling;
		uniform float _ScrollU;
		uniform float _ScrollY;
		uniform float _NormalScale;
		uniform float _FallSpeed;
		uniform float _OpacityNoise;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _Refraction;
		uniform float4 _WaterColor;
		uniform float _BaseReflection;
		uniform float _Metallic;
		uniform float _Smoothness;


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


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult54 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 temp_output_55_0 = ( appendResult54 * _Tilling );
			float mulTime3 = _Time.y * _ScrollU;
			float mulTime26 = _Time.y * _ScrollY;
			float2 appendResult27 = (float2(mulTime3 , mulTime26));
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 break62 = abs( ase_normWorldNormal );
			float mulTime72 = _Time.y * _FallSpeed;
			float temp_output_97_0 = ( ase_worldPos.y + mulTime72 );
			float2 appendResult71 = (float2(ase_worldPos.x , temp_output_97_0));
			float2 appendResult78 = (float2(ase_worldPos.z , temp_output_97_0));
			float3 normalizeResult79 = normalize( ( ( BlendNormals( UnpackScaleNormal( tex2D( _Normal, ( temp_output_55_0 + appendResult27 ) ), _NormalScale ) , UnpackScaleNormal( tex2D( _Normal, ( temp_output_55_0 - appendResult27 ) ), _NormalScale ) ) * break62.y ) + ( UnpackScaleNormal( tex2D( _Normal, ( appendResult71 * _Tilling ) ), _NormalScale ) * break62.z ) + ( UnpackScaleNormal( tex2D( _Normal, ( appendResult78 * _Tilling ) ), _NormalScale ) * break62.x ) ) );
			float3 break107 = abs( normalizeResult79 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor40 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( (ase_grabScreenPosNorm).xy + ( ase_grabScreenPosNorm.b * (normalizeResult79).xy * _Refraction ) ));
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float fresnelNdotV38 = dot( mul(ase_tangentToWorldFast,normalizeResult79), ase_worldViewDir );
			float fresnelNode38 = ( _BaseReflection + _Metallic * pow( 1.0 - fresnelNdotV38, 1.0 ) );
			float3 indirectNormal41 = WorldNormalVector( i , normalizeResult79 );
			Unity_GlossyEnvironmentData g41 = UnityGlossyEnvironmentSetup( _Smoothness, data.worldViewDir, indirectNormal41, float3(0,0,0));
			float3 indirectSpecular41 = UnityGI_IndirectSpecular( data, 1.0, indirectNormal41, g41 );
			c.rgb = ( ( screenColor40 * _WaterColor * ( 1.0 - fresnelNode38 ) ) + float4( ( indirectSpecular41 * fresnelNode38 ) , 0.0 ) ).rgb;
			c.a = saturate( ( i.vertexColor.r - ( ( 1.0 - i.vertexColor.r ) * break107.x * break107.y * _OpacityNoise ) ) );
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
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
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
				float4 screenPos : TEXCOORD1;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
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
Version=18301
11;-1074;1906;1050;3348.903;-285.3199;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;99;-2833.186,42.74958;Inherit;False;2175.392;1146.992;Comment;33;53;15;25;54;3;47;26;27;55;35;2;67;68;51;62;50;1;9;63;65;64;28;29;73;74;71;78;97;70;98;72;66;79;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;53;-2783.186,128.677;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;98;-2730.793,786.7415;Inherit;False;Property;_FallSpeed;FallSpeed;11;0;Create;True;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2673.598,471.4688;Inherit;False;Property;_ScrollY;ScrollY;8;0;Create;True;0;0;False;0;False;0.06123;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2664.271,388.8034;Inherit;False;Property;_ScrollU;ScrollU;7;0;Create;True;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;26;-2490.477,472.2024;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;70;-2678.493,597.7414;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;72;-2586.793,786.7415;Inherit;False;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;54;-2592.394,161.9424;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2608.5,268.1823;Inherit;False;Property;_Tilling;Tilling;1;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-2481.149,389.537;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-2436.394,163.9424;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-2295.037,412.8355;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-2362.793,754.7415;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;71;-2202.793,626.7415;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-1994.794,434.7415;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1978.794,242.7415;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;50;-1882.794,1010.741;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;35;-2260.104,92.74958;Inherit;False;Property;_NormalScale;NormalScale;3;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;78;-2202.793,818.7415;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;51;-1690.794,1010.741;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1;-1770.794,226.7415;Inherit;True;Property;_Normal;Normal;2;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-1994.794,626.7415;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;2;-1770.794,418.7415;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1994.794,818.7415;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendNormalsNode;9;-1434.794,306.7415;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;67;-1770.794,610.7415;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;68;-1770.794,802.7415;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;62;-1562.794,1010.741;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1162.794,802.7415;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1162.794,306.7415;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1162.794,610.7415;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-970.7939,578.7415;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;79;-842.7939,578.7415;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-480,16;Inherit;False;Property;_Refraction;Refraction;9;0;Create;True;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;11;-864,-192;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;30;-527.6923,-63.18671;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;102;352,736;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-225.8266,532.6344;Inherit;False;Property;_Metallic;Metallic;4;0;Create;True;0;0;False;0;False;0.9;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-148.1777,381.718;Inherit;False;Property;_BaseReflection;BaseReflection;6;0;Create;True;0;0;False;0;False;0.05;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;12;-624,-208;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-304,-112;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;108;314.7955,608.7259;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-128,-192;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-249.8266,312.6344;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;103;563.869,824.2958;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;107;427.5012,603.9582;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FresnelNode;38;216.2742,361.8467;Inherit;False;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;533.9314,921.1035;Inherit;False;Property;_OpacityNoise;OpacityNoise;10;0;Create;True;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;760.5595,794.5316;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;40;146.5244,-215.8457;Inherit;False;Global;_GrabScreen0;Grab Screen 0;0;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;37;90.85358,4.578463;Inherit;False;Property;_WaterColor;WaterColor;0;0;Create;True;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;39;451.2392,375.1278;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;41;183.4833,218.2536;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;469.1102,225.9317;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;912.869,767.2958;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;686.6242,-75.59782;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;106;1044.522,778.1573;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;958.9688,201.6095;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1294,-38;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Vket/Environment/SimpleWaterTriplanar;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;100;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;26;0;25;0
WireConnection;72;0;98;0
WireConnection;54;0;53;1
WireConnection;54;1;53;3
WireConnection;3;0;15;0
WireConnection;55;0;54;0
WireConnection;55;1;47;0
WireConnection;27;0;3;0
WireConnection;27;1;26;0
WireConnection;97;0;70;2
WireConnection;97;1;72;0
WireConnection;71;0;70;1
WireConnection;71;1;97;0
WireConnection;29;0;55;0
WireConnection;29;1;27;0
WireConnection;28;0;55;0
WireConnection;28;1;27;0
WireConnection;78;0;70;3
WireConnection;78;1;97;0
WireConnection;51;0;50;0
WireConnection;1;1;28;0
WireConnection;1;5;35;0
WireConnection;73;0;71;0
WireConnection;73;1;47;0
WireConnection;2;1;29;0
WireConnection;2;5;35;0
WireConnection;74;0;78;0
WireConnection;74;1;47;0
WireConnection;9;0;1;0
WireConnection;9;1;2;0
WireConnection;67;1;73;0
WireConnection;67;5;35;0
WireConnection;68;1;74;0
WireConnection;68;5;35;0
WireConnection;62;0;51;0
WireConnection;65;0;68;0
WireConnection;65;1;62;0
WireConnection;63;0;9;0
WireConnection;63;1;62;1
WireConnection;64;0;67;0
WireConnection;64;1;62;2
WireConnection;66;0;63;0
WireConnection;66;1;64;0
WireConnection;66;2;65;0
WireConnection;79;0;66;0
WireConnection;30;0;79;0
WireConnection;12;0;11;0
WireConnection;33;0;11;3
WireConnection;33;1;30;0
WireConnection;33;2;34;0
WireConnection;108;0;79;0
WireConnection;31;0;12;0
WireConnection;31;1;33;0
WireConnection;103;0;102;1
WireConnection;107;0;108;0
WireConnection;38;0;79;0
WireConnection;38;1;45;0
WireConnection;38;2;13;0
WireConnection;104;0;103;0
WireConnection;104;1;107;0
WireConnection;104;2;107;1
WireConnection;104;3;109;0
WireConnection;40;0;31;0
WireConnection;39;0;38;0
WireConnection;41;0;79;0
WireConnection;41;1;14;0
WireConnection;44;0;41;0
WireConnection;44;1;38;0
WireConnection;105;0;102;1
WireConnection;105;1;104;0
WireConnection;43;0;40;0
WireConnection;43;1;37;0
WireConnection;43;2;39;0
WireConnection;106;0;105;0
WireConnection;46;0;43;0
WireConnection;46;1;44;0
WireConnection;0;9;106;0
WireConnection;0;13;46;0
ASEEND*/
//CHKSM=9C5FC8F027C940D0E9F087CF16F7AD82A3854EA8