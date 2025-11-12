Shader "Custom/Multitextura Mascara (Ejercicio Cumplido)"
{
    Properties
    {
        _MainTex ("1. Textura Base (Negro)", 2D) = "white" {}
        _Tex2 ("2. Textura Secundaria (Blanco)", 2D) = "white" {}
        _MaskTex ("3. Máscara de Mezcla", 2D) = "gray" {}
        _Color ("Color Base (Tint)", Color) = (1,1,1,1)
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
            float4 _MainTex_ST; 

            sampler2D _Tex2;
            sampler2D _MaskTex;
            fixed4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0; 
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0; 
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // Asegura que el tiling y offset se apliquen a las UVs
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Paso 1: Muestreo
                fixed4 tex1 = tex2D(_MainTex, i.uv); // Textura 1
                fixed4 tex2 = tex2D(_Tex2, i.uv);    // Textura 2
                fixed4 mask = tex2D(_MaskTex, i.uv); // Máscara

                // Paso 2: Obtener el valor de mezcla (r)
                // Usamos el canal rojo de la máscara (escala de grises)
                float blendValue = mask.r; 
                
                // Paso 3: Combinar las texturas (Lerp)
                // lerp(A, B, t)
                // Si 't' (blendValue) es 0 (negro), el resultado es A (Textura 1).
                // Si 't' (blendValue) es 1 (blanco), el resultado es B (Textura 2).
                fixed4 finalColor = lerp(tex1, tex2, blendValue);

                // Resultado: La máscara en blanco muestra la Textura 2, y en negro la Textura 1.
                return finalColor * _Color;
            }
            ENDCG
        }
    }
}