Shader "Custom/LambertAmbientSpecular"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _AmbientColor ("Ambient Light", Color) = (0.15,0.15,0.15,1)
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Shininess ("Shininess", Range(8, 256)) = 32
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float4 _AmbientColor;
            float4 _SpecularColor;   //  Renombrado, ya NO causa conflicto
            float _Shininess;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 tex = tex2D(_MainTex, i.uv) * _Color;

                float3 N = normalize(i.worldNormal);

                // luz direccional
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;

                float NdotL = saturate(dot(N, L));
                float3 diffuse = tex.rgb * lightColor * NdotL;


                float3 ambient =
                    tex.rgb *
                    (_AmbientColor.rgb + UNITY_LIGHTMODEL_AMBIENT.xyz);

 
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 R = reflect(-L, N);

                float spec = pow(max(0, dot(R, V)), _Shininess);

                float3 specular = _SpecularColor.rgb * lightColor * spec;

                float3 finalColor = diffuse + ambient + specular;

                return float4(finalColor, tex.a);
            }

            ENDCG
        }
    }
}
