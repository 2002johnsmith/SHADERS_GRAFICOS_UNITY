Shader "Unlit/A1_shader"
{
    Properties
    {
        _baseColorB("color_A", Color )= (1,1,1,1)
        _baseColorA("color_B", Color )= (1,1,1,1)
        _Lerp("Lerp", Range(0,1))=1
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
            // make fog work
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

            uniform float4 _baseColorA;
            uniform float4 _baseColorB;
            uniform float _Lerp;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                return lerp(_baseColorA,_baseColorB,_Lerp);
            }
            ENDCG
        }
    }
}
