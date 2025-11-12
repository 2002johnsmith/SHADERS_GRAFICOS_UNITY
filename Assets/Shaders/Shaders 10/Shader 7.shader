Shader "Custom/ToonUnity6"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _Steps ("Toon Steps", Range(1,5)) = 3
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineSize ("Outline Size", Range(0,0.05)) = 0.02
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        // OUTLINE PASS
        Pass
        {
            Name "Outline"
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _OutlineSize;
            float4 _OutlineColor;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
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

        // MAIN TOON PASS
        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;
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

                float3 worldN = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                o.normalWorld = worldN;

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 N = normalize(i.normalWorld);

                float3 L = normalize(UnityWorldSpaceLightDir(i.worldPos));

                float NdotL = max(0, dot(N, L));

                float toon = floor(NdotL * _Steps) / _Steps;

                float4 tex = tex2D(_MainTex, i.uv) * _BaseColor;

                return float4(tex.rgb * toon, tex.a);
            }
            ENDCG
        }
    }
}
