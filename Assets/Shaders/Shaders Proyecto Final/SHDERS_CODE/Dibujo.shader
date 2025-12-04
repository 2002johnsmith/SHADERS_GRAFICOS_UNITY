Shader "Custom/TextureApplyShader"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {} // La textura principal
        _TilingX ("Tiling X", Range(1, 10)) = 1.0   // Controla el escalado de la textura en el eje X
        _TilingY ("Tiling Y", Range(1, 10)) = 1.0   // Controla el escalado de la textura en el eje Y
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Propiedades
            sampler2D _MainTex;
            float _TilingX;
            float _TilingY;

            // Estructuras de entrada y salida
            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Vertex Shader: Pasamos las coordenadas UV sin alterarlas
            v2f vert(appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                // Escalar las UVs según los parámetros Tiling
                o.uv = v.uv * float2(_TilingX, _TilingY);
                return o;
            }

            // Fragment Shader: Aplicamos la textura
            half4 frag(v2f i) : SV_Target
            {
                // Obtener el color de la textura utilizando las coordenadas UV escaladas
                half4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
