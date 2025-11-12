Shader "Custom/TextureLambertSpecularAmbient"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _AmbientColor("Ambient Color", Color) = (0.2,0.2,0.2,1)
        _LightColor("Light Color", Color) = (1,1,1,1)
        _LightDir("Light Direction", Vector) = (0, 1, 0, 0)
        _SpecColor("Specular Color", Color) = (1,1,1,1)
        _Shininess("Shininess", Range(8,128)) = 32
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _AmbientColor;
            float4 _LightColor;
            float4 _LightDir;
            float4 _SpecColor;
            float _Shininess;

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
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 N = normalize(i.worldNormal);

                // dirección de luz manual
                float3 L = normalize(-_LightDir.xyz);

                float lambert = max(dot(N, L), 0);

                float3 ambient = _AmbientColor.rgb;

                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 R = reflect(-L, N);
                float spec = pow(max(dot(R, V), 0), _Shininess);

                float3 tex = tex2D(_MainTex, i.uv).rgb;

                float3 finalColor =
                    tex * lambert * _LightColor.rgb +
                    tex * ambient +
                    spec * _SpecColor.rgb;

                return float4(finalColor, 1);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
