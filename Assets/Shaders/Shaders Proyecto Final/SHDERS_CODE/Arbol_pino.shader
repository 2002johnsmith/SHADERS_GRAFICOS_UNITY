Shader "Custom/URP/TwoColorReplaceWithScaling"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" {}

        // Canal 1
        _TargetColor1 ("Target Color 1", Color) = (0, 1, 0, 1)
        _Threshold1 ("Threshold 1", Range(0,1)) = 0.2
        _ReplaceTex1 ("Replacement Texture 1", 2D) = "white" {}
        _Tex1ScaleX ("Texture 1 Scale X", Range(0.1, 50.0)) = 1.0 // Escala de textura 1 en X
        _Tex1ScaleY ("Texture 1 Scale Y", Range(0.1, 50.0)) = 1.0 // Escala de textura 1 en Y

        // Canal 2
        _TargetColor2 ("Target Color 2", Color) = (1, 0, 0, 1)
        _Threshold2 ("Threshold 2", Range(0,1)) = 0.2
        _ReplaceTex2 ("Replacement Texture 2", 2D) = "white" {}
        _Tex2ScaleX ("Texture 2 Scale X", Range(0.1, 5.0)) = 1.0 // Escala de textura 2 en X
        _Tex2ScaleY ("Texture 2 Scale Y", Range(0.1, 1.0)) = 1.0 // Escala de textura 2 en Y
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            // Canal 1
            float4 _TargetColor1;
            float _Threshold1;
            TEXTURE2D(_ReplaceTex1);
            SAMPLER(sampler_ReplaceTex1);
            float _Tex1ScaleX; // Escala de textura 1 en X
            float _Tex1ScaleY; // Escala de textura 1 en Y

            // Canal 2
            float4 _TargetColor2;
            float _Threshold2;
            TEXTURE2D(_ReplaceTex2);
            SAMPLER(sampler_ReplaceTex2);
            float _Tex2ScaleX; // Escala de textura 2 en X
            float _Tex2ScaleY; // Escala de textura 2 en Y

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            // Función para detectar color basado en distancia RGB
            float DetectColor(float3 baseColor, float3 targetColor, float threshold)
            {
                float dist = distance(baseColor, targetColor);
                return step(dist, threshold);  // Retorna 1 si está cerca del color, 0 si no.
            }

            float4 frag(Varyings IN) : SV_Target
            {
                // Muestra el color de la textura base
                float4 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);

                // Detectar color 1 y color 2
                float mask1 = DetectColor(baseCol.rgb, _TargetColor1.rgb, _Threshold1);
                float mask2 = DetectColor(baseCol.rgb, _TargetColor2.rgb, _Threshold2);

                // Obtener las texturas de reemplazo
                float4 rep1 = SAMPLE_TEXTURE2D(_ReplaceTex1, sampler_ReplaceTex1, IN.uv);
                float4 rep2 = SAMPLE_TEXTURE2D(_ReplaceTex2, sampler_ReplaceTex2, IN.uv);

                // Ajuste de UV: Escala las texturas según las propiedades de escala X y Y
                float2 adjustedUV1 = IN.uv * float2(_Tex1ScaleX, _Tex1ScaleY); // Escalar UV para textura 1
                float2 adjustedUV2 = IN.uv * float2(_Tex2ScaleX, _Tex2ScaleY); // Escalar UV para textura 2

                // Reemplazar el color de la textura base por las texturas correspondientes
                baseCol = lerp(baseCol, SAMPLE_TEXTURE2D(_ReplaceTex1, sampler_ReplaceTex1, adjustedUV1), mask1);  // Reemplazar con textura 1
                baseCol = lerp(baseCol, SAMPLE_TEXTURE2D(_ReplaceTex2, sampler_ReplaceTex2, adjustedUV2), mask2);  // Reemplazar con textura 2

                return baseCol;  // Devolver el color modificado
            }

            ENDHLSL
        }
    }
}
