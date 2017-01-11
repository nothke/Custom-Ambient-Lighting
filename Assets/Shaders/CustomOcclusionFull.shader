
Shader "Custom/CustomOcclusionFull" {
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}

		//_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5/

		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		_GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
		[Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

		[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
		_MetallicGlossMap("Metallic", 2D) = "white" {}

		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

		_BumpScale("Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}

		_Parallax("Height Scale", Range(0.005, 0.08)) = 0.02
		_ParallaxMap("Height Map", 2D) = "black" {}

		_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
		_OcclusionMap("Occlusion", 2D) = "white" {}

		_EmissionColor("Color", Color) = (0,0,0)
		_EmissionMap("Emission", 2D) = "white" {}

		_DetailMask("Detail Mask", 2D) = "white" {}

		_DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
		_DetailNormalMapScale("Scale", Float) = 1.0
		_DetailNormalMap("Normal Map", 2D) = "bump" {}

		[Enum(UV0,0,UV1,1)] _UVSec("UV Set for secondary textures", Float) = 0

		// Blending state
		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			#pragma   surface surf Standard fullforwardshadows vertex:vert

			#pragma target 3.0

			#include "UnityPBSLighting.cginc"

			sampler2D _MainTex;
			fixed4 _Color;

			sampler2D _DetailAlbedoMap;
			sampler2D _BumpMap;
			sampler2D _MetallicGlossMap;

			float _Metallic;
			float _BumpScale;
			float _GlossMapScale;

			int _OcclusionPointsLength = 0;
			half3 _OcclusionPositions[64];
			half3 _OcclusionData[64];

			struct Input {
				float2 uv_MainTex;
				float4 color;
			};

			void vert(inout appdata_full v, out Input o)
			{
				UNITY_INITIALIZE_OUTPUT(Input, o);

				// get world position
				float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.color.a = 1;

				for (int i = 0; i < _OcclusionPointsLength; i++)
				{
					float minR = _OcclusionData[i].x;
					float maxR = _OcclusionData[i].y;

					// calculate occlusion per vertex as distance position
					maxR = clamp(maxR, 0.0001, 100000);
					float l = length(_OcclusionPositions[i] - wPos);
					float occ = (-minR + l) / (maxR - minR);

					// added inverse square for softer, less linear occ
					// possibly expensive, comment if it is
					occ = 1 - (sqrt(1 - occ));

					o.color.a = min(occ, o.color.a);
				}

				o.color.a = saturate(o.color.a);

				// debug
				//if (o.color.a < 1) o.color.a = 0;
			}

			



			void surf(Input IN, inout SurfaceOutputStandard o) {
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;

				o.Occlusion = IN.color.a;

				o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_MainTex), _BumpScale);
				// Metallic
				fixed4 mc = tex2D(_MetallicGlossMap, IN.uv_MainTex);
				o.Metallic = mc.r * _Metallic;
				o.Smoothness = mc.a * _GlossMapScale;
				o.Alpha = c.a;

				// DEBUG occlusion with black and white:
				//o.Albedo = IN.color.a;
				//o.Emission = IN.color.a;
				// end DEBUG occlusion
			}
			ENDCG
		}
			FallBack "Diffuse"
}
