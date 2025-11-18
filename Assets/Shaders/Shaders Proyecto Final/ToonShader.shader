Shader "URP/ToonShaderURP"
{
    Properties
    {
        _MainColor ("Color Principal", Color) = (1,1,1,1)
        _ShadowColor ("Color de Sombra", Color) = (0.2,0.2,0.2,1)
        _Shades ("Niveles de Sombra", Range(1,5)) = 3

        _OutlineColor ("Color Contorno", Color) = (0,0,0,1)
        _OutlineSize ("Grosor Contorno", Range(0,0.1)) = 0.03
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        // -----------------------------
        // OUTLINE PASS
        // -----------------------------
        Pass
        {
            Name "Outline"
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _OutlineColor;
            float _OutlineSize;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;

                float3 normalWS = normalize(TransformObjectToWorldNormal(v.normalOS));
                float3 posWS = TransformObjectToWorld(v.positionOS).xyz;

                posWS += normalWS * _OutlineSize;

                o.positionHCS = TransformWorldToHClip(posWS);
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                return _OutlineColor;
            }

            ENDHLSL
        }

        // -----------------------------
        // TOON PASS (URP LIGHTING)
        // -----------------------------
        Pass
        {
            Name "Toon"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float4 _MainColor;
            float4 _ShadowColor;
            float _Shades;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 posWS : TEXCOORD1;
            };

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS);
                o.normalWS = normalize(TransformObjectToWorldNormal(v.normalOS));
                o.posWS = TransformObjectToWorld(v.positionOS).xyz;
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                // Luz principal URP
                Light mainLight = GetMainLight();
                float3 L = normalize(mainLight.direction);

                float NdotL = saturate(dot(normalize(i.normalWS), L));

                // Toon steps
                float toon = floor(NdotL * _Shades) / _Shades;

                float3 col = lerp(_ShadowColor.rgb, _MainColor.rgb, toon);

                // Multiplicar por color de luz correcta URP
                col *= mainLight.color;

                return half4(col, 1);
            }

            ENDHLSL
        }
    }
}
