Shader "Unlit/A3_VinetaColor"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1,1,1,1)
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

            uniform float4 _BaseColor;
            uniform float4 _VignetteColor;
            uniform float _Intensity;
            uniform float _Power;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 center = float2(0.5, 0.5);
                float dist = distance(i.uv, center);

                float vignette = pow(saturate(dist * 2.0), _Power);

                float factor = saturate(vignette * _Intensity);
                fixed4 color = lerp(_BaseColor, _VignetteColor, factor);

                return color;
            }
            ENDCG
        }
    }
}
