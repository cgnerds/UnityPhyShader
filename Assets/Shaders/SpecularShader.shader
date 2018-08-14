﻿Shader "Custom/SpecularShader"
{
	Properties
	{
		_DiffuseTex("Texture", 2D) = "white"{}
		_Color("Color", Color) = (1, 0, 0, 1)
		_Ambient("Ambient", Range(0,1)) = 0.25
		_SpecColor("Specular Material Color", Color) = (1, 1, 1, 1)
		_Shininess("Shininess", Float) = 10
	}

	SubShader
	{
		Tags { "LightMode"="ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertexClip: SV_POSITION;
				float4 vertexWorld : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};
			
            sampler2D _DiffuseTex;
			float4 _DiffuseTex_ST;
			float4 _Color;
			float _Ambient;
			float _Shininess;


			v2f vert (appdata v)
			{
				v2f o;
				o.vertexClip = UnityObjectToClipPos(v.vertex);
				o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal); // calculate world normal
				o.worldNormal = worldNormal; // assign to output data structure
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 normalDirection = normalize(i.worldNormal);
				float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.vertexWorld));
				float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));

				// sample the texture
				float4 tex = tex2D(_DiffuseTex, i.uv);

				// Diffuse implementation (Lambert)
				float nl = max(_Ambient, dot(normalDirection, lightDirection));
				float4 diffuseTerm = nl * _Color * tex * _LightColor0;

				// Specular implementation (Phong)
				float3 refelectionDirection = reflect(-lightDirection, normalDirection);
				float3 specularDot = max(0.0, dot(viewDirection, refelectionDirection));
				float3 specular = pow(specularDot, _Shininess);
				float4 specularTerm = float4(specular, 1) * _SpecColor * _LightColor0;

				float4 finalColor = diffuseTerm + specularTerm;
				return finalColor;
			}
			ENDCG
		}
	}
}