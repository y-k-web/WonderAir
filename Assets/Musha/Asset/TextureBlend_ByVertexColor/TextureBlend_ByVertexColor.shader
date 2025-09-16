// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:True,hqlp:False,rprd:True,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:2865,x:33000,y:32075,varname:node_2865,prsc:2|diff-2380-OUT,spec-358-OUT,gloss-1813-OUT,normal-8982-OUT,emission-4425-OUT;n:type:ShaderForge.SFN_Slider,id:358,x:32474,y:32287,ptovrint:False,ptlb:Metallic,ptin:_Metallic,varname:node_358,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Slider,id:1813,x:32474,y:32393,ptovrint:False,ptlb:Gloss,ptin:_Gloss,varname:_Metallic_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_VertexColor,id:5205,x:32967,y:32874,varname:node_5205,prsc:2;n:type:ShaderForge.SFN_Lerp,id:1443,x:32313,y:32126,varname:node_1443,prsc:2|A-8681-OUT,B-5958-OUT,T-5205-G;n:type:ShaderForge.SFN_Lerp,id:6000,x:32457,y:32638,varname:node_6000,prsc:2|A-4558-OUT,B-7622-RGB,T-5205-G;n:type:ShaderForge.SFN_Multiply,id:615,x:32144,y:31976,varname:node_615,prsc:2|A-7721-RGB,B-9933-RGB;n:type:ShaderForge.SFN_Multiply,id:5958,x:32208,y:32384,varname:node_5958,prsc:2|A-3545-RGB,B-8644-RGB;n:type:ShaderForge.SFN_Multiply,id:5736,x:31574,y:32262,varname:node_5736,prsc:2|A-5596-RGB,B-5348-RGB;n:type:ShaderForge.SFN_Lerp,id:2380,x:32578,y:32124,varname:node_2380,prsc:2|A-1443-OUT,B-615-OUT,T-5205-R;n:type:ShaderForge.SFN_Lerp,id:8982,x:32735,y:32633,varname:node_8982,prsc:2|A-6000-OUT,B-4324-RGB,T-5205-R;n:type:ShaderForge.SFN_Lerp,id:6561,x:32475,y:33044,varname:node_6561,prsc:2|A-8309-OUT,B-4297-RGB,T-5205-G;n:type:ShaderForge.SFN_Lerp,id:4425,x:32779,y:33044,varname:node_4425,prsc:2|A-6561-OUT,B-4451-RGB,T-5205-R;n:type:ShaderForge.SFN_Tex2d,id:7721,x:31702,y:31895,ptovrint:False,ptlb:Tex(RED),ptin:_TexRED,varname:node_7721,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:3545,x:31733,y:32388,ptovrint:False,ptlb:Tex(GREEN),ptin:_TexGREEN,varname:node_3545,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:5596,x:31209,y:32265,ptovrint:False,ptlb:Tex(BLUE),ptin:_TexBLUE,varname:node_5596,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:9933,x:31692,y:32086,ptovrint:False,ptlb:Color(RED),ptin:_ColorRED,varname:node_9933,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Color,id:8644,x:31733,y:32564,ptovrint:False,ptlb:Color(GREEN),ptin:_ColorGREEN,varname:node_8644,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Color,id:5348,x:31209,y:32513,ptovrint:False,ptlb:Color(BLUE),ptin:_ColorBLUE,varname:node_5348,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Color,id:4451,x:32475,y:33192,ptovrint:False,ptlb:Emissive(RED),ptin:_EmissiveRED,varname:node_4451,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Color,id:4297,x:32228,y:33192,ptovrint:False,ptlb:Emissive(GREEN),ptin:_EmissiveGREEN,varname:node_4297,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Color,id:594,x:31952,y:33192,ptovrint:False,ptlb:Emissive(BLUE),ptin:_EmissiveBLUE,varname:node_594,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:0;n:type:ShaderForge.SFN_Tex2d,id:4324,x:32475,y:32846,ptovrint:False,ptlb:Normal(RED),ptin:_NormalRED,varname:node_4324,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:7622,x:32228,y:32846,ptovrint:False,ptlb:Normal(GREEN),ptin:_NormalGREEN,varname:node_7622,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:9389,x:31948,y:32849,ptovrint:False,ptlb:Normal(BLUE),ptin:_NormalBLUE,varname:node_9389,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Lerp,id:8681,x:32124,y:32126,varname:node_8681,prsc:2|A-5529-OUT,B-5736-OUT,T-5205-B;n:type:ShaderForge.SFN_Vector3,id:5529,x:31893,y:32114,varname:node_5529,prsc:2,v1:0,v2:0,v3:0;n:type:ShaderForge.SFN_Vector3,id:9963,x:31733,y:32735,varname:node_9963,prsc:2,v1:0,v2:0,v3:0;n:type:ShaderForge.SFN_Lerp,id:4558,x:32230,y:32638,varname:node_4558,prsc:2|A-9963-OUT,B-9389-RGB,T-5205-B;n:type:ShaderForge.SFN_Lerp,id:8309,x:32228,y:33044,varname:node_8309,prsc:2|A-1937-OUT,B-594-RGB,T-5205-B;n:type:ShaderForge.SFN_Vector3,id:1937,x:31948,y:33044,varname:node_1937,prsc:2,v1:0,v2:0,v3:0;proporder:358-1813-7721-3545-5596-9933-8644-5348-4451-4297-594-4324-7622-9389;pass:END;sub:END;*/

Shader "Shader Forge/TextureBlend_ByVertexColor" {
    Properties {
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Gloss ("Gloss", Range(0, 1)) = 0
        _TexRED ("Tex(RED)", 2D) = "white" {}
        _TexGREEN ("Tex(GREEN)", 2D) = "white" {}
        _TexBLUE ("Tex(BLUE)", 2D) = "white" {}
        _ColorRED ("Color(RED)", Color) = (1,1,1,1)
        _ColorGREEN ("Color(GREEN)", Color) = (1,1,1,1)
        _ColorBLUE ("Color(BLUE)", Color) = (1,1,1,1)
        _EmissiveRED ("Emissive(RED)", Color) = (0,0,0,1)
        _EmissiveGREEN ("Emissive(GREEN)", Color) = (0,0,0,1)
        _EmissiveBLUE ("Emissive(BLUE)", Color) = (0,0,0,0)
        _NormalRED ("Normal(RED)", 2D) = "bump" {}
        _NormalGREEN ("Normal(GREEN)", 2D) = "bump" {}
        _NormalBLUE ("Normal(BLUE)", 2D) = "bump" {}
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float _Metallic;
            uniform float _Gloss;
            uniform sampler2D _TexRED; uniform float4 _TexRED_ST;
            uniform sampler2D _TexGREEN; uniform float4 _TexGREEN_ST;
            uniform sampler2D _TexBLUE; uniform float4 _TexBLUE_ST;
            uniform float4 _ColorRED;
            uniform float4 _ColorGREEN;
            uniform float4 _ColorBLUE;
            uniform float4 _EmissiveRED;
            uniform float4 _EmissiveGREEN;
            uniform float4 _EmissiveBLUE;
            uniform sampler2D _NormalRED; uniform float4 _NormalRED_ST;
            uniform sampler2D _NormalGREEN; uniform float4 _NormalGREEN_ST;
            uniform sampler2D _NormalBLUE; uniform float4 _NormalBLUE_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 posWorld : TEXCOORD3;
                float3 normalDir : TEXCOORD4;
                float3 tangentDir : TEXCOORD5;
                float3 bitangentDir : TEXCOORD6;
                float4 vertexColor : COLOR;
                LIGHTING_COORDS(7,8)
                UNITY_FOG_COORDS(9)
                #if defined(LIGHTMAP_ON) || defined(UNITY_SHOULD_SAMPLE_SH)
                    float4 ambientOrLightmapUV : TEXCOORD10;
                #endif
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.uv2 = v.texcoord2;
                o.vertexColor = v.vertexColor;
                #ifdef LIGHTMAP_ON
                    o.ambientOrLightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    o.ambientOrLightmapUV.zw = 0;
                #elif UNITY_SHOULD_SAMPLE_SH
                #endif
                #ifdef DYNAMICLIGHTMAP_ON
                    o.ambientOrLightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _NormalBLUE_var = UnpackNormal(tex2D(_NormalBLUE,TRANSFORM_TEX(i.uv0, _NormalBLUE)));
                float3 _NormalGREEN_var = UnpackNormal(tex2D(_NormalGREEN,TRANSFORM_TEX(i.uv0, _NormalGREEN)));
                float3 _NormalRED_var = UnpackNormal(tex2D(_NormalRED,TRANSFORM_TEX(i.uv0, _NormalRED)));
                float3 normalLocal = lerp(lerp(lerp(float3(0,0,0),_NormalBLUE_var.rgb,i.vertexColor.b),_NormalGREEN_var.rgb,i.vertexColor.g),_NormalRED_var.rgb,i.vertexColor.r);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float gloss = _Gloss;
                float perceptualRoughness = 1.0 - _Gloss;
                float roughness = perceptualRoughness * perceptualRoughness;
                float specPow = exp2( gloss * 10.0 + 1.0 );
/////// GI Data:
                UnityLight light;
                #ifdef LIGHTMAP_OFF
                    light.color = lightColor;
                    light.dir = lightDirection;
                    light.ndotl = LambertTerm (normalDirection, light.dir);
                #else
                    light.color = half3(0.f, 0.f, 0.f);
                    light.ndotl = 0.0f;
                    light.dir = half3(0.f, 0.f, 0.f);
                #endif
                UnityGIInput d;
                d.light = light;
                d.worldPos = i.posWorld.xyz;
                d.worldViewDir = viewDirection;
                d.atten = attenuation;
                #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                    d.ambient = 0;
                    d.lightmapUV = i.ambientOrLightmapUV;
                #else
                    d.ambient = i.ambientOrLightmapUV;
                #endif
                #if UNITY_SPECCUBE_BLENDING || UNITY_SPECCUBE_BOX_PROJECTION
                    d.boxMin[0] = unity_SpecCube0_BoxMin;
                    d.boxMin[1] = unity_SpecCube1_BoxMin;
                #endif
                #if UNITY_SPECCUBE_BOX_PROJECTION
                    d.boxMax[0] = unity_SpecCube0_BoxMax;
                    d.boxMax[1] = unity_SpecCube1_BoxMax;
                    d.probePosition[0] = unity_SpecCube0_ProbePosition;
                    d.probePosition[1] = unity_SpecCube1_ProbePosition;
                #endif
                d.probeHDR[0] = unity_SpecCube0_HDR;
                d.probeHDR[1] = unity_SpecCube1_HDR;
                Unity_GlossyEnvironmentData ugls_en_data;
                ugls_en_data.roughness = 1.0 - gloss;
                ugls_en_data.reflUVW = viewReflectDirection;
                UnityGI gi = UnityGlobalIllumination(d, 1, normalDirection, ugls_en_data );
                lightDirection = gi.light.dir;
                lightColor = gi.light.color;
////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float LdotH = saturate(dot(lightDirection, halfDirection));
                float3 specularColor = _Metallic;
                float specularMonochrome;
                float4 _TexBLUE_var = tex2D(_TexBLUE,TRANSFORM_TEX(i.uv0, _TexBLUE));
                float4 _TexGREEN_var = tex2D(_TexGREEN,TRANSFORM_TEX(i.uv0, _TexGREEN));
                float4 _TexRED_var = tex2D(_TexRED,TRANSFORM_TEX(i.uv0, _TexRED));
                float3 diffuseColor = lerp(lerp(lerp(float3(0,0,0),(_TexBLUE_var.rgb*_ColorBLUE.rgb),i.vertexColor.b),(_TexGREEN_var.rgb*_ColorGREEN.rgb),i.vertexColor.g),(_TexRED_var.rgb*_ColorRED.rgb),i.vertexColor.r); // Need this for specular when using metallic
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, specularMonochrome );
                specularMonochrome = 1.0-specularMonochrome;
                float NdotV = abs(dot( normalDirection, viewDirection ));
                float NdotH = saturate(dot( normalDirection, halfDirection ));
                float VdotH = saturate(dot( viewDirection, halfDirection ));
                float visTerm = SmithJointGGXVisibilityTerm( NdotL, NdotV, roughness );
                float normTerm = GGXTerm(NdotH, roughness);
                float specularPBL = (visTerm*normTerm) * UNITY_PI;
                #ifdef UNITY_COLORSPACE_GAMMA
                    specularPBL = sqrt(max(1e-4h, specularPBL));
                #endif
                specularPBL = max(0, specularPBL * NdotL);
                #if defined(_SPECULARHIGHLIGHTS_OFF)
                    specularPBL = 0.0;
                #endif
                half surfaceReduction;
                #ifdef UNITY_COLORSPACE_GAMMA
                    surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;
                #else
                    surfaceReduction = 1.0/(roughness*roughness + 1.0);
                #endif
                specularPBL *= any(specularColor) ? 1.0 : 0.0;
                float3 directSpecular = attenColor*specularPBL*FresnelTerm(specularColor, LdotH);
                half grazingTerm = saturate( gloss + specularMonochrome );
                float3 indirectSpecular = (gi.indirect.specular);
                indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
                indirectSpecular *= surfaceReduction;
                float3 specular = (directSpecular + indirectSpecular);
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
                float nlPow5 = Pow5(1-NdotL);
                float nvPow5 = Pow5(1-NdotV);
                float3 directDiffuse = ((1 +(fd90 - 1)*nlPow5) * (1 + (fd90 - 1)*nvPow5) * NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += gi.indirect.diffuse;
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
////// Emissive:
                float3 emissive = lerp(lerp(lerp(float3(0,0,0),_EmissiveBLUE.rgb,i.vertexColor.b),_EmissiveGREEN.rgb,i.vertexColor.g),_EmissiveRED.rgb,i.vertexColor.r);
/// Final Color:
                float3 finalColor = diffuse + specular + emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float _Metallic;
            uniform float _Gloss;
            uniform sampler2D _TexRED; uniform float4 _TexRED_ST;
            uniform sampler2D _TexGREEN; uniform float4 _TexGREEN_ST;
            uniform sampler2D _TexBLUE; uniform float4 _TexBLUE_ST;
            uniform float4 _ColorRED;
            uniform float4 _ColorGREEN;
            uniform float4 _ColorBLUE;
            uniform float4 _EmissiveRED;
            uniform float4 _EmissiveGREEN;
            uniform float4 _EmissiveBLUE;
            uniform sampler2D _NormalRED; uniform float4 _NormalRED_ST;
            uniform sampler2D _NormalGREEN; uniform float4 _NormalGREEN_ST;
            uniform sampler2D _NormalBLUE; uniform float4 _NormalBLUE_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 posWorld : TEXCOORD3;
                float3 normalDir : TEXCOORD4;
                float3 tangentDir : TEXCOORD5;
                float3 bitangentDir : TEXCOORD6;
                float4 vertexColor : COLOR;
                LIGHTING_COORDS(7,8)
                UNITY_FOG_COORDS(9)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.uv2 = v.texcoord2;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _NormalBLUE_var = UnpackNormal(tex2D(_NormalBLUE,TRANSFORM_TEX(i.uv0, _NormalBLUE)));
                float3 _NormalGREEN_var = UnpackNormal(tex2D(_NormalGREEN,TRANSFORM_TEX(i.uv0, _NormalGREEN)));
                float3 _NormalRED_var = UnpackNormal(tex2D(_NormalRED,TRANSFORM_TEX(i.uv0, _NormalRED)));
                float3 normalLocal = lerp(lerp(lerp(float3(0,0,0),_NormalBLUE_var.rgb,i.vertexColor.b),_NormalGREEN_var.rgb,i.vertexColor.g),_NormalRED_var.rgb,i.vertexColor.r);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float gloss = _Gloss;
                float perceptualRoughness = 1.0 - _Gloss;
                float roughness = perceptualRoughness * perceptualRoughness;
                float specPow = exp2( gloss * 10.0 + 1.0 );
////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float LdotH = saturate(dot(lightDirection, halfDirection));
                float3 specularColor = _Metallic;
                float specularMonochrome;
                float4 _TexBLUE_var = tex2D(_TexBLUE,TRANSFORM_TEX(i.uv0, _TexBLUE));
                float4 _TexGREEN_var = tex2D(_TexGREEN,TRANSFORM_TEX(i.uv0, _TexGREEN));
                float4 _TexRED_var = tex2D(_TexRED,TRANSFORM_TEX(i.uv0, _TexRED));
                float3 diffuseColor = lerp(lerp(lerp(float3(0,0,0),(_TexBLUE_var.rgb*_ColorBLUE.rgb),i.vertexColor.b),(_TexGREEN_var.rgb*_ColorGREEN.rgb),i.vertexColor.g),(_TexRED_var.rgb*_ColorRED.rgb),i.vertexColor.r); // Need this for specular when using metallic
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, specularMonochrome );
                specularMonochrome = 1.0-specularMonochrome;
                float NdotV = abs(dot( normalDirection, viewDirection ));
                float NdotH = saturate(dot( normalDirection, halfDirection ));
                float VdotH = saturate(dot( viewDirection, halfDirection ));
                float visTerm = SmithJointGGXVisibilityTerm( NdotL, NdotV, roughness );
                float normTerm = GGXTerm(NdotH, roughness);
                float specularPBL = (visTerm*normTerm) * UNITY_PI;
                #ifdef UNITY_COLORSPACE_GAMMA
                    specularPBL = sqrt(max(1e-4h, specularPBL));
                #endif
                specularPBL = max(0, specularPBL * NdotL);
                #if defined(_SPECULARHIGHLIGHTS_OFF)
                    specularPBL = 0.0;
                #endif
                specularPBL *= any(specularColor) ? 1.0 : 0.0;
                float3 directSpecular = attenColor*specularPBL*FresnelTerm(specularColor, LdotH);
                float3 specular = directSpecular;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
                float nlPow5 = Pow5(1-NdotL);
                float nvPow5 = Pow5(1-NdotV);
                float3 directDiffuse = ((1 +(fd90 - 1)*nlPow5) * (1 + (fd90 - 1)*nvPow5) * NdotL) * attenColor;
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor * 1,0);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "Meta"
            Tags {
                "LightMode"="Meta"
            }
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_META 1
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "UnityMetaPass.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float _Metallic;
            uniform float _Gloss;
            uniform sampler2D _TexRED; uniform float4 _TexRED_ST;
            uniform sampler2D _TexGREEN; uniform float4 _TexGREEN_ST;
            uniform sampler2D _TexBLUE; uniform float4 _TexBLUE_ST;
            uniform float4 _ColorRED;
            uniform float4 _ColorGREEN;
            uniform float4 _ColorBLUE;
            uniform float4 _EmissiveRED;
            uniform float4 _EmissiveGREEN;
            uniform float4 _EmissiveBLUE;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 posWorld : TEXCOORD3;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.uv2 = v.texcoord2;
                o.vertexColor = v.vertexColor;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST );
                return o;
            }
            float4 frag(VertexOutput i) : SV_Target {
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );
                
                o.Emission = lerp(lerp(lerp(float3(0,0,0),_EmissiveBLUE.rgb,i.vertexColor.b),_EmissiveGREEN.rgb,i.vertexColor.g),_EmissiveRED.rgb,i.vertexColor.r);
                
                float4 _TexBLUE_var = tex2D(_TexBLUE,TRANSFORM_TEX(i.uv0, _TexBLUE));
                float4 _TexGREEN_var = tex2D(_TexGREEN,TRANSFORM_TEX(i.uv0, _TexGREEN));
                float4 _TexRED_var = tex2D(_TexRED,TRANSFORM_TEX(i.uv0, _TexRED));
                float3 diffColor = lerp(lerp(lerp(float3(0,0,0),(_TexBLUE_var.rgb*_ColorBLUE.rgb),i.vertexColor.b),(_TexGREEN_var.rgb*_ColorGREEN.rgb),i.vertexColor.g),(_TexRED_var.rgb*_ColorRED.rgb),i.vertexColor.r);
                float specularMonochrome;
                float3 specColor;
                diffColor = DiffuseAndSpecularFromMetallic( diffColor, _Metallic, specColor, specularMonochrome );
                float roughness = 1.0 - _Gloss;
                o.Albedo = diffColor + specColor * roughness * roughness * 0.5;
                
                return UnityMetaFragment( o );
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
