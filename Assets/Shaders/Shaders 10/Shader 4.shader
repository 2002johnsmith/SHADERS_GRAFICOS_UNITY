Shader "Custom/TextureAmbient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientColor ("Ambient Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _AmbientColor;

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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 tex = tex2D(_MainTex, i.uv);

                // iluminación ambiental manual (Unity 6 compatible)
                fixed3 ambient = _AmbientColor.rgb;

                return fixed4(tex.rgb * ambient, tex.a);
            }
            ENDCG
        }
    }
}
