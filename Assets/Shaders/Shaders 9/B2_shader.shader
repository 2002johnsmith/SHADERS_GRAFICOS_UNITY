Shader "Unlit/B2_ScrollUV"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _ScrollDir("Scroll Direction (X,Y)", Vector) = (1,0,0,0)
        _Speed("Scroll Speed", Range(0,10)) = 1
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
            float2 _ScrollDir;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Calcular desplazamiento de UVs en el tiempo
                float2 uv = i.uv + _ScrollDir * _Speed * _Time.y;

                // Muestrear textura desplazada
                fixed4 col = tex2D(_MainTex, uv);

                return col;
            }
            ENDCG
        }
    }
}
