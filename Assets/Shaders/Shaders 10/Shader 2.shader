Shader "Custom/LambertAmbient_Fixed2"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _AmbientColor ("Ambient Light", Color) = (0.15,0.15,0.15,1)
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
            #include "UnityLightingCommon.cginc" //  Aquí vienen las luces del Built-in

            sampler2D _MainTex;
            float4 _Color;
            float4 _AmbientColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                // Normal en espacio mundial
                o.normalDir = normalize(UnityObjectToWorldNormal(v.normal));
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 tex = tex2D(_MainTex, i.uv) * _Color;

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); 
                float3 lightColor = _LightColor0.rgb; 

                float NdotL = max(0, dot(i.normalDir, lightDir));
                float3 diffuse = tex.rgb * lightColor * NdotL;

                float3 ambient = tex.rgb * (UNITY_LIGHTMODEL_AMBIENT.xyz + _AmbientColor.rgb);

                float3 finalColor = diffuse + ambient;

                return float4(finalColor, tex.a);
            }

            ENDCG
        }
    }
}
