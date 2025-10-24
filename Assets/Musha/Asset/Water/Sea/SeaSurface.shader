// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "uniuni/SeaSurface"
{
	Properties
	{
		_WaterColor("WaterColor", Color) = (1,1,1,0)
		_UnderSeaColor("UnderSeaColor", Color) = (1,1,1,0)
		_Tilling("Tilling", Float) = 1
		[NoScaleOffset][Normal][SingleLineTexture]_OffsetNormal("OffsetNormal", 2D) = "bump" {}
		[NoScaleOffset][Normal][SingleLineTexture]_Normal("Normal", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 1
		_UnderMetallic("UnderMetallic", Range( 0 , 1)) = 0.9
		_Metallic("Metallic", Range( 0 , 1)) = 0.9
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_FarSmoothness("FarSmoothness", Range( 0 , 1)) = 1
		_BaseReflection("BaseReflection", Range( 0 , 1)) = 0.05
		_ScrollU("ScrollU", Float) = 0.05
		_farMetallic("farMetallic", Range( 0 , 1)) = 0
		_ScrollY("ScrollY", Float) = 0.06123
		_SeaLevel("SeaLevel", Float) = 0
		_Refraction("Refraction", Float) = 0.5
		_Height("Height", 2D) = "gray" {}
		_HightOffsetPow("HightOffsetPow", Float) = 0
		_HightOffset("HightOffset", Float) = 0
		_ApparentMeanCurvature("ApparentMeanCurvature", Float) = 0
		_OffsetLevel("OffsetLevel", Float) = 0.002
		_FarShiftSharpness("FarShiftSharpness", Float) = 10
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+100" "IgnoreProjector" = "True" }
		Cull Off
		AlphaToMask On
		GrabPass{ }
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
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
			float3 worldPos;
			float4 screenPos;
			float4 vertexColor : COLOR;
			INTERNAL_DATA
			float3 worldNormal;
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

		uniform sampler2D _Height;
		uniform sampler2D _OffsetNormal;
		uniform float _SeaLevel;
		uniform float _Tilling;
		uniform float _ScrollU;
		uniform float _ScrollY;
		uniform float _OffsetLevel;
		uniform float _HightOffsetPow;
		uniform float _HightOffset;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _Normal;
		uniform float _NormalScale;
		uniform float _Refraction;
		uniform float4 _WaterColor;
		uniform float _ApparentMeanCurvature;
		uniform float _BaseReflection;
		uniform float _UnderMetallic;
		uniform float _Metallic;
		uniform float _farMetallic;
		uniform float _FarShiftSharpness;
		uniform float _Smoothness;
		uniform float _FarSmoothness;
		uniform float4 _UnderSeaColor;


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
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float temp_output_68_0 = ( _WorldSpaceCameraPos.y - _SeaLevel );
			float dotResult50 = dot( ase_worldViewDir , float3(0,1,0) );
			float VDirDotUP60 = dotResult50;
			float2 appendResult114 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 lerpResult115 = lerp( (( _WorldSpaceCameraPos + ( -ase_worldViewDir * ( temp_output_68_0 / VDirDotUP60 ) ) )).xz , appendResult114 , v.color.r);
			float2 WorldSpaceUV75 = lerpResult115;
			float2 temp_output_77_0 = ( WorldSpaceUV75 * _Tilling );
			float2 temp_output_79_0 = ( temp_output_77_0 * float2( 0.03,0.03 ) );
			float mulTime3 = _Time.y * _ScrollU;
			float mulTime26 = _Time.y * _ScrollY;
			float2 appendResult89 = (float2(mulTime3 , -mulTime26));
			float2 temp_output_93_0 = ( appendResult89 * float2( 0.1,0.1 ) );
			float2 appendResult173 = (float2(_WorldSpaceCameraPos.x , _WorldSpaceCameraPos.z));
			float temp_output_174_0 = distance( appendResult173 , WorldSpaceUV75 );
			float2 appendResult27 = (float2(mulTime3 , mulTime26));
			float2 temp_output_219_0 = ( ( ( (UnpackNormal( tex2Dlod( _OffsetNormal, float4( ( temp_output_79_0 + temp_output_93_0 ), 0, 0.0) ) )).xy * _OffsetLevel * temp_output_174_0 ) + ( temp_output_77_0 + appendResult27 ) ) * float2( 0.9,0.9 ) );
			float2 temp_output_84_0 = ( ( (UnpackNormal( tex2Dlod( _OffsetNormal, float4( ( temp_output_79_0 - temp_output_93_0 ), 0, 0.0) ) )).xy * _OffsetLevel * temp_output_174_0 ) + ( temp_output_77_0 - appendResult27 ) );
			float3 Height98 = ( (tex2Dlod( _Height, float4( temp_output_219_0, 0, 0.0) )).rgb + (tex2Dlod( _Height, float4( temp_output_84_0, 0, 0.0) )).rgb );
			float3 appendResult122 = (float3(0.0 , _HightOffsetPow , 0.0));
			float3 appendResult132 = (float3(0.0 , _HightOffset , 0.0));
			v.vertex.xyz += ( ( Height98 * appendResult122 ) + appendResult132 );
			v.vertex.w = 1;
			v.normal = float3(0,1,0);
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float temp_output_68_0 = ( _WorldSpaceCameraPos.y - _SeaLevel );
			float CmeraSide182 = ceil( saturate( temp_output_68_0 ) );
			float lerpResult184 = lerp( 1.0 , ase_worldViewDir.y , CmeraSide182);
			float temp_output_1_0_g1 = lerpResult184;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float dotResult50 = dot( ase_worldViewDir , float3(0,1,0) );
			float VDirDotUP60 = dotResult50;
			float2 appendResult114 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 lerpResult115 = lerp( (( _WorldSpaceCameraPos + ( -ase_worldViewDir * ( temp_output_68_0 / VDirDotUP60 ) ) )).xz , appendResult114 , i.vertexColor.r);
			float2 WorldSpaceUV75 = lerpResult115;
			float2 temp_output_77_0 = ( WorldSpaceUV75 * _Tilling );
			float2 temp_output_79_0 = ( temp_output_77_0 * float2( 0.03,0.03 ) );
			float mulTime3 = _Time.y * _ScrollU;
			float mulTime26 = _Time.y * _ScrollY;
			float2 appendResult89 = (float2(mulTime3 , -mulTime26));
			float2 temp_output_93_0 = ( appendResult89 * float2( 0.1,0.1 ) );
			float2 appendResult173 = (float2(_WorldSpaceCameraPos.x , _WorldSpaceCameraPos.z));
			float temp_output_174_0 = distance( appendResult173 , WorldSpaceUV75 );
			float2 appendResult27 = (float2(mulTime3 , mulTime26));
			float2 temp_output_219_0 = ( ( ( (UnpackNormal( tex2D( _OffsetNormal, ( temp_output_79_0 + temp_output_93_0 ) ) )).xy * _OffsetLevel * temp_output_174_0 ) + ( temp_output_77_0 + appendResult27 ) ) * float2( 0.9,0.9 ) );
			float2 temp_output_84_0 = ( ( (UnpackNormal( tex2D( _OffsetNormal, ( temp_output_79_0 - temp_output_93_0 ) ) )).xy * _OffsetLevel * temp_output_174_0 ) + ( temp_output_77_0 - appendResult27 ) );
			float3 temp_output_150_0 = BlendNormals( UnpackScaleNormal( tex2D( _Normal, temp_output_219_0 ), _NormalScale ) , UnpackScaleNormal( tex2D( _Normal, temp_output_84_0 ), _NormalScale ) );
			float3 Normal164 = temp_output_150_0;
			float4 screenColor40 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( (ase_grabScreenPosNorm).xy + ( ase_grabScreenPosNorm.b * (Normal164).xy * _Refraction ) ));
			float temp_output_51_0 = ( 1.0 - VDirDotUP60 );
			float3 break162 = temp_output_150_0;
			float3 appendResult163 = (float3(break162.x , break162.z , break162.y));
			float3 rotatedValue165 = RotateAroundAxis( float3( 0,0,0 ), appendResult163, cross( float3(0,1,0) , ase_worldViewDir ), ( _ApparentMeanCurvature * temp_output_51_0 ) );
			float3 WorldNormal62 = rotatedValue165;
			float3 break200 = WorldNormal62;
			float3 appendResult201 = (float3(break200.x , -break200.y , break200.z));
			float3 lerpResult186 = lerp( appendResult201 , WorldNormal62 , CmeraSide182);
			float temp_output_189_0 = saturate( pow( temp_output_51_0 , _FarShiftSharpness ) );
			float lerpResult105 = lerp( _Metallic , _farMetallic , temp_output_189_0);
			float lerpResult195 = lerp( _UnderMetallic , lerpResult105 , CmeraSide182);
			float fresnelNdotV38 = dot( lerpResult186, ase_worldViewDir );
			float fresnelNode38 = ( _BaseReflection + lerpResult195 * pow( 1.0 - fresnelNdotV38, 1.0 ) );
			float3 indirectNormal41 = lerpResult186;
			float lerpResult191 = lerp( ( 1.0 - temp_output_189_0 ) , temp_output_189_0 , CmeraSide182);
			float lerpResult59 = lerp( _Smoothness , _FarSmoothness , lerpResult191);
			Unity_GlossyEnvironmentData g41 = UnityGlossyEnvironmentSetup( lerpResult59, data.worldViewDir, indirectNormal41, float3(0,0,0));
			float3 indirectSpecular41 = UnityGI_IndirectSpecular( data, 1.0, indirectNormal41, g41 );
			float dotResult209 = dot( WorldNormal62 , ase_worldViewDir );
			float4 lerpResult198 = lerp( ( ( screenColor40 * _WaterColor * ( 1.0 - fresnelNode38 ) ) + float4( ( indirectSpecular41 * fresnelNode38 ) , 0.0 ) ) , _UnderSeaColor , ( ceil( dotResult209 ) * ( 1.0 - CmeraSide182 ) ));
			c.rgb = lerpResult198.rgb;
			c.a = saturate( ( ( ( temp_output_1_0_g1 - 0.0 ) / max( fwidth( temp_output_1_0_g1 ) , 0.0001 ) ) + 0.5 ) );
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
			#pragma target 4.6
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
Version=18712
-4;4;1920;1030;809.1971;636.8134;1.641406;True;False
Node;AmplifyShaderEditor.CommentaryNode;109;-2912,720;Inherit;False;1975.594;592.5671;BaseUV;22;75;74;72;71;73;70;60;68;67;50;66;49;48;113;114;115;117;159;161;181;182;188;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;48;-2784,992;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;49;-2784,1136;Inherit;False;Constant;_UP;UP;10;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;50;-2576,1056;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-2752,912;Inherit;False;Property;_SeaLevel;SeaLevel;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;67;-2864,768;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;-2569,891;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-2464,1056;Inherit;False;VDirDotUP;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;73;-2224,976;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;70;-2224,1056;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-2064,992;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;113;-1891.565,942.9131;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-1888,768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;114;-1696,976;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;117;-1875,1083;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;74;-1760,768;Inherit;False;True;False;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;115;-1488,944;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-4656,-48;Inherit;False;Property;_ScrollY;ScrollY;14;0;Create;True;0;0;0;False;0;False;0.06123;0.02135;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-4656,-128;Inherit;False;Property;_ScrollU;ScrollU;12;0;Create;True;0;0;0;False;0;False;0.05;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;110;-4704,-528;Inherit;False;2126.197;1183.538;NormalUV;9;76;172;173;171;174;82;88;176;219;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-1326,939;Inherit;False;WorldSpaceUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;26;-4464,-48;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;90;-4208,0;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-4256,-208;Inherit;False;Property;_Tilling;Tilling;3;0;Create;True;0;0;0;False;0;False;1;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-4464,-128;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-4288,-304;Inherit;False;75;WorldSpaceUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-4048,-288;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;-4048,-32;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-3833.219,-368.2744;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.03,0.03;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-3840,-32;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;171;-3880.741,153.1721;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-3568,-368;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;-3683.375,310.4581;Inherit;False;75;WorldSpaceUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;94;-3568,-48;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;173;-3589.375,186.4581;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;78;-3424,-448;Inherit;True;Property;_OffsetNormal;OffsetNormal;4;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;86;-3424,-80;Inherit;True;Property;_TextureSample2;Texture Sample 2;4;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;78;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;27;-4048,-176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;80;-3120,-336;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;174;-3383.243,257.3241;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-3170.776,191.3259;Inherit;False;Property;_OffsetLevel;OffsetLevel;21;0;Create;True;0;0;0;False;0;False;0.002;0.003;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-3568,-272;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-2913,-333;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0.002;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;87;-3136,-80;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-2928,-80;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0.002;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-3568,-144;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-2736,-288;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;111;-2512,-912;Inherit;False;1457.831;1330.56;Normal, Hight;27;57;169;98;128;125;126;62;96;95;165;163;170;166;164;162;167;168;51;150;61;2;1;177;189;190;191;193;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;-2721.925,-422.499;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.9,0.9;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2736,-608;Inherit;False;Property;_NormalScale;NormalScale;6;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-2736,-160;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-2496,-544;Inherit;True;Property;_Normal;Normal;5;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;3ab616ca4a1497946be66c0e266ba536;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-2496,-352;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;150;-2176,-464;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-2157.277,193.2428;Inherit;False;60;VDirDotUP;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;162;-1920,-464;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.OneMinusNode;51;-1965.278,193.2428;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;168;-2000,-848;Inherit;False;Constant;_Vector1;Vector 1;17;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;167;-2000,-704;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;169;-2064,112;Inherit;False;Property;_ApparentMeanCurvature;ApparentMeanCurvature;20;0;Create;True;0;0;0;False;0;False;0;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;163;-1776,-464;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;166;-1792,-784;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-1789.278,113.2428;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;165;-1568,-544;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-1264,-544;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;177;-2065.401,260.3215;Inherit;False;Property;_FarShiftSharpness;FarShiftSharpness;22;0;Create;True;0;0;0;False;0;False;10;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;188;-2421.987,887.3257;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-938.1982,-140.9643;Inherit;False;62;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;200;-704.683,-231.0199;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PowerNode;57;-1764.446,205.5018;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;164;-1952,-544;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CeilOpNode;181;-2275.048,879.9013;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;112;-820.0133,-1031.75;Inherit;False;1004;357;Refraction;8;30;31;33;12;11;63;34;40;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-738.0133,-805.7501;Inherit;False;164;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;189;-1609.737,203.4272;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-904.8829,290.148;Inherit;False;Property;_Metallic;Metallic;8;0;Create;True;0;0;0;False;0;False;0.9;0.323;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-898.3388,360.016;Inherit;False;Property;_farMetallic;farMetallic;13;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;-2145.514,874.665;Inherit;False;CmeraSide;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;187;-582.8888,-206.5922;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-635.7866,562.191;Inherit;False;182;CmeraSide;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-482.0133,-789.7501;Inherit;False;Property;_Refraction;Refraction;16;0;Create;True;0;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;-597.2083,-88.4652;Inherit;False;182;CmeraSide;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;196;-883.8486,459.4058;Inherit;False;Property;_UnderMetallic;UnderMetallic;7;0;Create;True;0;0;0;False;0;False;0.9;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;105;-603.3388,324.016;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;201;-423.683,-231.0199;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;96;-2496,32;Inherit;True;Property;_TextureSample3;Texture Sample 3;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;95;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;95;-2496,-160;Inherit;True;Property;_Height;Height;17;0;Create;True;0;0;0;False;0;False;-1;None;e964afe0c8a8f3b46953fff4b040656f;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;30;-529.7057,-868.9368;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;-1558.724,297.3298;Inherit;False;182;CmeraSide;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;193;-1374.849,107.4058;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;11;-770.0133,-981.7502;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;12;-370.0133,-981.7502;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;126;-2208,32;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-907.234,204.2316;Inherit;False;Property;_BaseReflection;BaseReflection;11;0;Create;True;0;0;0;False;0;False;0.05;0.01;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;186;-267.8315,-190.8356;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;125;-2208,-160;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;191;-1202.847,163.7595;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-669.1593,119.1199;Inherit;False;Property;_FarSmoothness;FarSmoothness;10;0;Create;True;0;0;0;False;0;False;1;0.803;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-674.0831,42.44799;Inherit;False;Property;_Smoothness;Smoothness;9;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-306.0133,-901.7502;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;195;-313.9097,335.6207;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;128;-1968,-64;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-133.7057,-924.9369;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;38;-11.78219,104.3603;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;167.7391,324.9986;Inherit;False;62;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;59;-335.1591,84.11991;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;208;195.2863,391.1392;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-1840,-64;Inherit;False;Height;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenColorNode;40;-18.01344,-933.7502;Inherit;False;Global;_GrabScreen0;Grab Screen 0;0;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;39;255.1829,115.6414;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;37;-44.32595,-656.3613;Inherit;False;Property;_WaterColor;WaterColor;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IndirectSpecularLight;41;-12.57308,-41.23282;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;211;360.8445,447.556;Inherit;False;182;CmeraSide;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;209;389.2249,330.9236;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;291.6954,718.7172;Inherit;False;Property;_HightOffsetPow;HightOffsetPow;18;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;273.0539,-33.55471;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;462.1927,-230.5889;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;451.6954,606.7172;Inherit;False;98;Height;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;214;543.1177,447.1841;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;122;483.6954,686.7172;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;131;323.6954,830.7172;Inherit;False;Property;_HightOffset;HightOffset;19;0;Create;True;0;0;0;False;0;False;0;-0.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;106;462.7763,-868.0569;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CeilOpNode;210;511.363,333.4311;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;449.8477,-731.97;Inherit;False;182;CmeraSide;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;659.6954,606.7172;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;132;483.6954,798.7172;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;184;704.8477,-833.97;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;688,-48;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;199;608,48;Inherit;False;Property;_UnderSeaColor;UnderSeaColor;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0.03605346,0.3207546,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;213;721.1783,326.0043;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;133;812.6953,623.7172;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;108;762.4539,789.7874;Inherit;False;Constant;_Vector0;Vector 0;16;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RoundOpNode;161;-1506.2,1197.28;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;198;919,-2;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;217;-414.2495,-467.0438;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;216;-639.1495,-542.4438;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;215;-718.449,-407.2439;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;180;874.3806,-836.6902;Inherit;False;SharpAlpha;-1;;1;36b0460b52d96d04882ceb50e9b42822;0;2;1;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;-265.1189,-464.7927;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;159;-1080.014,975.5297;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1408.688,-166.2658;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;uniuni/SeaSurface;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;100;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;50;0;48;0
WireConnection;50;1;49;0
WireConnection;68;0;67;2
WireConnection;68;1;66;0
WireConnection;60;0;50;0
WireConnection;73;0;48;0
WireConnection;70;0;68;0
WireConnection;70;1;60;0
WireConnection;71;0;73;0
WireConnection;71;1;70;0
WireConnection;72;0;67;0
WireConnection;72;1;71;0
WireConnection;114;0;113;1
WireConnection;114;1;113;3
WireConnection;74;0;72;0
WireConnection;115;0;74;0
WireConnection;115;1;114;0
WireConnection;115;2;117;1
WireConnection;75;0;115;0
WireConnection;26;0;25;0
WireConnection;90;0;26;0
WireConnection;3;0;15;0
WireConnection;77;0;76;0
WireConnection;77;1;47;0
WireConnection;89;0;3;0
WireConnection;89;1;90;0
WireConnection;79;0;77;0
WireConnection;93;0;89;0
WireConnection;92;0;79;0
WireConnection;92;1;93;0
WireConnection;94;0;79;0
WireConnection;94;1;93;0
WireConnection;173;0;171;1
WireConnection;173;1;171;3
WireConnection;78;1;92;0
WireConnection;86;1;94;0
WireConnection;27;0;3;0
WireConnection;27;1;26;0
WireConnection;80;0;78;0
WireConnection;174;0;173;0
WireConnection;174;1;172;0
WireConnection;28;0;77;0
WireConnection;28;1;27;0
WireConnection;82;0;80;0
WireConnection;82;1;176;0
WireConnection;82;2;174;0
WireConnection;87;0;86;0
WireConnection;88;0;87;0
WireConnection;88;1;176;0
WireConnection;88;2;174;0
WireConnection;29;0;77;0
WireConnection;29;1;27;0
WireConnection;83;0;82;0
WireConnection;83;1;28;0
WireConnection;219;0;83;0
WireConnection;84;0;88;0
WireConnection;84;1;29;0
WireConnection;1;1;219;0
WireConnection;1;5;35;0
WireConnection;2;1;84;0
WireConnection;2;5;35;0
WireConnection;150;0;1;0
WireConnection;150;1;2;0
WireConnection;162;0;150;0
WireConnection;51;0;61;0
WireConnection;163;0;162;0
WireConnection;163;1;162;2
WireConnection;163;2;162;1
WireConnection;166;0;168;0
WireConnection;166;1;167;0
WireConnection;170;0;169;0
WireConnection;170;1;51;0
WireConnection;165;0;166;0
WireConnection;165;1;170;0
WireConnection;165;3;163;0
WireConnection;62;0;165;0
WireConnection;188;0;68;0
WireConnection;200;0;64;0
WireConnection;57;0;51;0
WireConnection;57;1;177;0
WireConnection;164;0;150;0
WireConnection;181;0;188;0
WireConnection;189;0;57;0
WireConnection;182;0;181;0
WireConnection;187;0;200;1
WireConnection;105;0;13;0
WireConnection;105;1;104;0
WireConnection;105;2;189;0
WireConnection;201;0;200;0
WireConnection;201;1;187;0
WireConnection;201;2;200;2
WireConnection;96;1;84;0
WireConnection;95;1;219;0
WireConnection;30;0;63;0
WireConnection;193;0;189;0
WireConnection;12;0;11;0
WireConnection;126;0;96;0
WireConnection;186;0;201;0
WireConnection;186;1;64;0
WireConnection;186;2;185;0
WireConnection;125;0;95;0
WireConnection;191;0;193;0
WireConnection;191;1;189;0
WireConnection;191;2;190;0
WireConnection;33;0;11;3
WireConnection;33;1;30;0
WireConnection;33;2;34;0
WireConnection;195;0;196;0
WireConnection;195;1;105;0
WireConnection;195;2;194;0
WireConnection;128;0;125;0
WireConnection;128;1;126;0
WireConnection;31;0;12;0
WireConnection;31;1;33;0
WireConnection;38;0;186;0
WireConnection;38;1;45;0
WireConnection;38;2;195;0
WireConnection;59;0;14;0
WireConnection;59;1;58;0
WireConnection;59;2;191;0
WireConnection;98;0;128;0
WireConnection;40;0;31;0
WireConnection;39;0;38;0
WireConnection;41;0;186;0
WireConnection;41;1;59;0
WireConnection;209;0;207;0
WireConnection;209;1;208;0
WireConnection;44;0;41;0
WireConnection;44;1;38;0
WireConnection;43;0;40;0
WireConnection;43;1;37;0
WireConnection;43;2;39;0
WireConnection;214;0;211;0
WireConnection;122;1;121;0
WireConnection;210;0;209;0
WireConnection;101;0;99;0
WireConnection;101;1;122;0
WireConnection;132;1;131;0
WireConnection;184;1;106;2
WireConnection;184;2;183;0
WireConnection;46;0;43;0
WireConnection;46;1;44;0
WireConnection;213;0;210;0
WireConnection;213;1;214;0
WireConnection;133;0;101;0
WireConnection;133;1;132;0
WireConnection;161;0;117;1
WireConnection;198;0;46;0
WireConnection;198;1;199;0
WireConnection;198;2;213;0
WireConnection;217;0;216;0
WireConnection;217;1;215;0
WireConnection;180;1;184;0
WireConnection;218;0;217;0
WireConnection;159;0;75;0
WireConnection;0;9;180;0
WireConnection;0;13;198;0
WireConnection;0;11;133;0
WireConnection;0;12;108;0
ASEEND*/
//CHKSM=8BD41E8C21A10D46CA0152E2860A283A7E92C440