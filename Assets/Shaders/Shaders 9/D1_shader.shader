Shader "Unlit/D1_LerpTwoTextures"
{
    Properties
    {
        _MainTex("Texture A", 2D) = "white" {}
        _TexB("Texture B", 2D) = "gray" {}
        _Blend("Blend (0=A, 1=B)", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uvA : TEXCOORD0;
                float2 uvB : TEXCOORD1;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _TexB;
            float4 _MainTex_ST;
            float4 _TexB_ST;
            float _Blend;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Aplicar tiling/offset independientes
                o.uvA = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvB = TRANSFORM_TEX(v.uv, _TexB);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Muestreo de ambas texturas
                fixed4 colorA = tex2D(_MainTex, i.uvA);
                fixed4 colorB = tex2D(_TexB, i.uvB);

                // Mezcla lineal entre ambas
                fixed4 finalColor = lerp(colorA, colorB, _Blend);

                return finalColor;
            }
            ENDCG
        }
    }
}
