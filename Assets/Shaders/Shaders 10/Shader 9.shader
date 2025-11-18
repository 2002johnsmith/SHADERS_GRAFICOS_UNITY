Shader "Custom/Toon_MultiTexture_Mask_URP"
{
    Properties
    {
        // ---- MULTITEXTURA ----
        _MainTex ("1. Textura Base", 2D) = "white" {}
        _Tex2 ("2. Textura Secundaria", 2D) = "white" {}
        _MaskTex ("3. Máscara", 2D) = "gray" {}
        _Color ("Tint", Color) = (1,1,1,1)

        // ---- TOON ----
        _Steps ("Toon Steps", Range(1,5)) = 3

        // ---- OUTLINE ----
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineSize ("Outline Size", Range(0,0.05)) = 0.02
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }

        // ---------------------------------------------------------
        // ---------------------- OUTLINE PASS ---------------------
        // ---------------------------------------------------------
        Pass
        {
            Name "Outline"
            Tags { "LightMode"="SRPDefaultUnlit" }
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float _OutlineSize;
            float4 _OutlineColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                float3 N = normalize(v.normal);

                // Expandir la malla para el borde
                v.vertex.xyz += N * _OutlineSize;

                o.pos = TransformObjectToHClip(v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return _OutlineColor;
            }

            ENDHLSL
        }

        // ---------------------------------------------------------
        // ------------------ TOON + MULTITEXTURA ------------------
        // ---------------------------------------------------------
        Pass
        {
            Name "ToonLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // URP Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // TEXTURAS
            TEXTURE2D(_MainTex);   SAMPLER(sampler_MainTex);
            TEXTURE2D(_Tex2);      SAMPLER(sampler_Tex2);
            TEXTURE2D(_MaskTex);   SAMPLER(sampler_MaskTex);

            float4 _MainTex_ST;
            float4 _Color;

            // Toon
            float _Steps;

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
                float3 normalWS : TEXCOORD1;
                float3 posWS : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;

                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.posWS = TransformObjectToWorld(v.vertex).xyz;

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // ---------------- MULTITEXTURA ----------------
                float4 tex1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                float4 tex2 = SAMPLE_TEXTURE2D(_Tex2, sampler_Tex2, i.uv);
                float mask  = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uv).r;

                float4 mixedTex = lerp(tex1, tex2, mask) * _Color;

                // ------------------ ILUMINACIÓN URP ------------------
                Light mainLight = GetMainLight();
                float3 L = normalize(mainLight.direction);

                float3 N = normalize(i.normalWS);
                float NdotL = max(0, dot(N, L));

                // ------------------ TOON -----------------------
                float toon = floor(NdotL * _Steps) / _Steps;

                float3 finalColor = mixedTex.rgb * toon * mainLight.color;

                return float4(finalColor, mixedTex.a);
            }

            ENDHLSL
        }
    }
}
