Shader "Instanced/ToonGrass"
{
    Properties
    {
        _Color ("Color", Color) = (0.5, 0.65, 1, 1)
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _ShadowBands ("Shadow bands", Int) = 3
        _ShadowOffset ("Shadow offset", Range (0, 10)) = 1
        _ShadowDarkness ("Shadow darkness", Range (0, 1)) = 1
        _ShadowTint ("Shadow tint", Color) = (0.0, 0.35, .65, 1)
    }
    SubShader
    {
        Tags
        {
          "Queue"="AlphaTest"
          "IgnoreProjector"="True"
          "RenderType"="Grass"
        }
        //Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instanced
            #include "UnityCG.cginc"
            #include "Shadows.cginc"

            sampler2D _MainTex;
            StructuredBuffer<float4> positionBuffer;
            StructuredBuffer<float3> normBuffer;

            struct appdata
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float3 worldNormal: NORMAL;
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos: TEXCOORD1;
            };

            // Simple billboard vertex shader
            // Reference: https://www.youtube.com/watch?v=qGppGvgw7Dg
            v2f vert (appdata v, uint instanceID : SV_InstanceID)
            {
                v2f o;

                // Get position data from buffer for this instance
                float4 positionData = positionBuffer[instanceID];
                float3 normData = normBuffer[instanceID];

                // Origin of the object in world space
                float4 worldOrigin = mul(UNITY_MATRIX_M, float4(positionData.xyz, 1));

                // Origin of the object in view space
                float4 viewOrigin = float4(UnityObjectToViewPos(positionData.xyz), 1);

                // Local position of object
                float4 localPos = float4(v.vertex.xyz*positionData.w + positionData.xyz, 1);

                // Deconstruct the calls to render the vertex to clip space
                float4 worldPos = mul(UNITY_MATRIX_M, localPos); // Model matrix
                float4 viewPos = worldPos - worldOrigin + viewOrigin; // View matrix
                float4 clipPos = mul(UNITY_MATRIX_P, viewPos); // Perspective matrix

                o.uv = v.uv.xy;
                o.worldNormal = UnityObjectToWorldNormal(normData);
                o.worldPos = worldPos.xyz;
                o.pos = clipPos;
                return o;
            }

            int _ShadowBands;
            float _ShadowOffset, _ShadowDarkness;
            float4 _Color, _ShadowTint;
            fixed4 frag (v2f i) : SV_Target
            {
                float NdotL = dot(_WorldSpaceLightPos0, i.worldNormal);
                float NdotLNorm = 0.5 * (NdotL + 1);

                float lightIntensity = 1 - exp(-NdotLNorm + _ShadowOffset) * (1 - NdotLNorm);

                // Compute shadow attenuation
                half shadow = GetSunShadowsAttenuation(i.worldPos, 1.0);
                lightIntensity *= shadow;

                float bandedIntensity = ceil(lightIntensity * _ShadowBands) / _ShadowBands;
                bandedIntensity = lerp(1 - _ShadowDarkness, 1, bandedIntensity);
                float clampedIntensity = clamp(bandedIntensity, 1 - _ShadowDarkness, 1);
                float4 shadowTint = (1 - clampedIntensity) * _ShadowTint;

                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                float4 rgb = _Color * (clampedIntensity + shadowTint);
                col = float4(rgb.xyz, col.w);
                clip(col.a - 0.5);
                return col;
            }
            ENDCG
        }
    }
}
