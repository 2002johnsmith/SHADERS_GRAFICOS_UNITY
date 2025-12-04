Shader "URP/DibujoCartoon_Fixed"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Posterize("Posterize Levels", Range(2, 20)) = 6
        _EdgeThreshold("Edge Threshold", Range(0.01, 1)) = 0.2
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

            float3 Posterize(float3 c, float lv)
            {
                return floor(c * lv) / lv;
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

            float4 frag(Varyings IN) : SV_Target
            {
                float4 col = tex2D(_MainTex, IN.uv);

                col.rgb = Posterize(col.rgb, _Posterize);

                float edge = SobelEdge(IN.uv);
                if (edge > _EdgeThreshold)
                    col.rgb = 0;

                return col;
            }

            ENDHLSL
        }
    }
}
