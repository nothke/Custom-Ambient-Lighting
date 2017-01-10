
Shader "Custom/CustomOcclusion" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			#pragma   surface surf Standard fullforwardshadows vertex:vert

			#pragma target 3.0

			#include "UnityPBSLighting.cginc"

			sampler2D _MainTex;

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

					o.color.a = min(occ, o.color.a);
				}

				o.color.a = saturate(o.color.a);

				// debug
				//if (o.color.a < 1) o.color.a = 0;
			}

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;



			void surf(Input IN, inout SurfaceOutputStandard o) {
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;

				o.Occlusion = IN.color.a;

				//o.Albedo += 0.4;
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;

				// debug occlusion
				//o.Albedo = IN.color.a;
				//o.Emission = IN.color.a;
				// end debug occlusion
			}
			ENDCG
		}
			FallBack "Diffuse"
}
