Shader "URP/DibujoCartoon_Abstracto"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Posterize("Posterize Levels", Range(2, 20)) = 6
        _EdgeThreshold("Edge Threshold", Range(0.01, 1)) = 0.2
        _NoiseAmount("Noise Amount", Range(0.0, 1.0)) = 0.1
        _Saturation("Saturation", Range(0.0, 2.0)) = 1.0
    }

    SubShader
    {
        Tags 
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        Pass
        {
            Name "ForwardUnlit"
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Posterize;
            float _EdgeThreshold;
            float _NoiseAmount;
            float _Saturation;

            float3 Posterize(float3 c, float lv)
            {
                return floor(c * lv) / lv;
            }

            // Reemplazar fract con una operación equivalente en HLSL
            float fract(float x)
            {
                return x - floor(x);
            }

            // Functión para agregar ruido a la textura (simula un efecto de pincel)
            float3 AddNoise(float2 uv, float amount)
            {
                float noise = fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                return float3(noise * amount, noise * amount, noise * amount);
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            float SobelEdge(float2 uv)
            {
                float2 px = float2(1.0 / 1024.0, 1.0 / 1024.0);

                float3 tl = tex2D(_MainTex, uv + px * float2(-1,-1)).rgb;
                float3 t  = tex2D(_MainTex, uv + px * float2( 0,-1)).rgb;
                float3 tr = tex2D(_MainTex, uv + px * float2( 1,-1)).rgb;
                float3 l  = tex2D(_MainTex, uv + px * float2(-1, 0)).rgb;
                float3 r  = tex2D(_MainTex, uv + px * float2( 1, 0)).rgb;
                float3 bl = tex2D(_MainTex, uv + px * float2(-1, 1)).rgb;
                float3 b  = tex2D(_MainTex, uv + px * float2( 0, 1)).rgb;
                float3 br = tex2D(_MainTex, uv + px * float2( 1, 1)).rgb;

                float3 gx = -tl - 2*l - bl + tr + 2*r + br;
                float3 gy = -tl - 2*t - tr + bl + 2*b + br;

                return length(gx + gy);
            }

            // Función para ajustar la saturación de los colores
            float3 AdjustSaturation(float3 color, float saturation)
            {
                float grey = dot(color, float3(0.299, 0.587, 0.114));
                return lerp(float3(grey, grey, grey), color, saturation);
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float4 col = tex2D(_MainTex, IN.uv);

                // Aplicar posterización
                col.rgb = Posterize(col.rgb, _Posterize);

                // Ajustar saturación
                col.rgb = AdjustSaturation(col.rgb, _Saturation);

                // Añadir ruido
                col.rgb += AddNoise(IN.uv, _NoiseAmount);

                // Aplicar bordes
                float edge = SobelEdge(IN.uv);
                if (edge > _EdgeThreshold)
                    col.rgb = float3(0, 0, 0); // Negro en los bordes

                return col;
            }

            ENDHLSL
        }
    }
}
