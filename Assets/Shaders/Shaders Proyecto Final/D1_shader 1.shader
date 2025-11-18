Shader "Custom/ToonShader_STRUCTURED"
{
    Properties
    {
        _MainColor ("Color Principal", Color) = (0.6, 0.6, 0.6, 1)
        _ShadowColor ("Color de Sombra", Color) = (0.3, 0.3, 0.3, 1)
        _Shades ("Numero de Bandas de Sombra", Range(1, 4)) = 2

        _OutlineColor("Color del Contorno", Color) = (0, 0, 1, 1)
        _OutlineSize("Grosor del Contorno", Range(0, 0.1)) = 0.015
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            Name "Outline"
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 _OutlineColor;
            float _OutlineSize;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                float3 n = normalize(v.normal);
                v.vertex.xyz += n * _OutlineSize;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        Pass
        {
            Name "ToonShading"
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _MainColor;
            float4 _ShadowColor;
            float _Shades;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.worldNormal);

                // Dirección de luz direccional
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                // Toon bands
                float NdotL = max(0, dot(N, L));
                float toonStep = floor(NdotL * _Shades + 0.5) / _Shades;

                // Color base interpolado
                float3 rgb = lerp(_ShadowColor.rgb, _MainColor.rgb, toonStep);

                // Luz direccional
                rgb *= _LightColor0.rgb * toonStep;

                // Luz ambiental
                rgb += UNITY_LIGHTMODEL_AMBIENT.rgb * _MainColor.rgb;

                return fixed4(rgb, _MainColor.a);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
