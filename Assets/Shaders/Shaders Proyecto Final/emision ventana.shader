Shader "Custom/URP/CelesteReplace"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _ReplacementColor ("Color Celeste Reemplazo", Color) = (0, 1, 1, 1)
        _EmissionColor ("Emision", Color) = (0, 1, 1, 1)
        _EmissionStrength ("Fuerza Emision", Range(0,10)) = 1
        _BlueThreshold ("Umbral Azul", Range(0,1)) = 0.6
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

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

            float4 _ReplacementColor;
            float4 _EmissionColor;
            float _EmissionStrength;
            float _BlueThreshold;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // leer color base
                float4 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);

                // detecta si es celeste (mucho azul y algo de verde)
                float blue = baseCol.b;
                float green = baseCol.g;

                float mask = step(_BlueThreshold, blue) * step(0.3, green);

                // aplica el color reemplazo solo donde mask = 1
                float4 finalColor = lerp(baseCol, _ReplacementColor, mask);

                // emisión solo en zonas reemplazadas
                float3 emission = _EmissionColor.rgb * _EmissionStrength * mask;

                return float4(finalColor.rgb + emission, 1.0);
            }
            ENDHLSL
        }
    }
}
