// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/CustomAmbient" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		//_OcclusionPosition("Occlusion pos", Vector) = (0,0,0,0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma   surface surf Standard fullforwardshadows vertex:vert // noambient

		#pragma target 3.0

		#include "UnityPBSLighting.cginc"

		sampler2D _MainTex;
		half4 _OcclusionPosition;

		struct Input {
			float2 uv_MainTex;
			float4 color;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			// get world position
			float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

			// calculate occlusion per vertex as distance position
			float r = _OcclusionPosition.w;
			r = clamp(r, 0.0001, 10000);
			o.color.a = length(_OcclusionPosition - wPos) / r;

			o.color.a = saturate(o.color.a);

			// v.vertex.xyz += v.normal * 1;
		}

		inline half4 LightingStandardDefaultGI(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
		{
			return LightingStandard(s, viewDir, gi);
		}

		inline void LightingStandardDefaultGI_GI(
			SurfaceOutputStandard s,
			UnityGIInput data,
			inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi);
			
			gi.light.color = 0;
		}



		half _Glossiness;
		half _Metallic;
		fixed4 _Color;



		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;

			o.Occlusion = IN.color.a;

			//o.Albedo += 0.4;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;

			// debug occlusion
			o.Albedo = IN.color.a;
			o.Emission = IN.color.a;
			// end debug occlusion
		}
		ENDCG
	}
	FallBack "Diffuse"
}
