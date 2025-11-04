Shader "Custom/D3_CutoutMask"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Mask("Mask (A)", 2D) = "white" {}
        _Threshold("Cutout Threshold", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" } 
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _Mask;
            float4 _MainTex_ST;
            float _Threshold;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                fixed mask = tex2D(_Mask, i.uv).r;

                // Recorta según umbral
                clip(mask - _Threshold);

                return color;
            }
            ENDCG
        }
    }
}
