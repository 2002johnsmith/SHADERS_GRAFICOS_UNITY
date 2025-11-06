Shader "Unlit/C2_MixTextureColor"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _SolidColor("Solid Color", Color) = (1,1,1,1)
        _Mix("Mix (0=Texture, 1=Color)", Range(0,1)) = 0.5
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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _SolidColor;
            float _Mix;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Muestreo del color base de la textura
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Mezclar entre textura y color plano
                fixed4 finalColor = lerp(texColor, _SolidColor, _Mix);

                return finalColor;
            }
            ENDCG
        }
    }
}
