Shader "Custom/Toon_MultiTexture_Mask"
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
        Tags { "RenderType" = "Opaque" }

        // ---------------------------------------------------------
        // ---------------------- OUTLINE PASS ---------------------
        // ---------------------------------------------------------
        Pass
        {
            Name "Outline"
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
                v.vertex.xyz += N * _OutlineSize;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        // ---------------------------------------------------------
        // ------------------ TOON + MULTITEXTURA ------------------
        // ---------------------------------------------------------
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // MULTITEXTURA
            sampler2D _MainTex;
            sampler2D _Tex2;
            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float4 _Color;

            // TOON
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
                float3 normalWorld : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normalWorld = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // ---------------- MULTITEXTURA ----------------
                float4 tex1 = tex2D(_MainTex, i.uv);
                float4 tex2 = tex2D(_Tex2, i.uv);
                float mask = tex2D(_MaskTex, i.uv).r;

                float4 mixedTex = lerp(tex1, tex2, mask) * _Color;

                // ------------------ TOON -----------------------
                float3 N = normalize(i.normalWorld);
                float3 L = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float NdotL = max(0, dot(N, L));

                float toonStep = floor(NdotL * _Steps) / _Steps;

                return float4(mixedTex.rgb * toonStep, mixedTex.a);
            }
            ENDCG
        }
    }
}
