Shader "Unlit/C3_VignetteTexture"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _VignetteColor("Vignette Color", Color) = (0,0,0,1)
        _Intensity("Intensity", Range(0,1)) = 0.5
        _Power("Power", Range(0.1,8)) = 2.0
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
            float4 _VignetteColor;
            float _Intensity;
            float _Power;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Muestreo de la textura base
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Calcular distancia desde el centro (para el efecto radial)
                float2 center = float2(0.5, 0.5);
                float dist = distance(i.uv, center);

                // Curva de caída con potencia (ajusta la suavidad del borde)
                float vignette = pow(saturate(dist * 2.0), _Power);

                // Factor de mezcla controlado por intensidad
                float factor = saturate(vignette * _Intensity);

                // Aplicar viñeta sobre la textura
                fixed4 finalColor = lerp(texColor, _VignetteColor, factor);

                return finalColor;
            }
            ENDCG
        }
    }
}
