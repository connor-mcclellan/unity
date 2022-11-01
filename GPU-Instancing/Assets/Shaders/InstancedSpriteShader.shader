Shader "Instanced/InstancedSpriteShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // Takes in the 2D texture
    }
    SubShader
    {
        Tags { "Queue"="Transparent" } // Render to the transparent queue
        Blend SrcAlpha OneMinusSrcAlpha // Enables transparent sprites
        Lighting Off
        ZWrite Off // Allows transparent sprites to render on top of each other
        Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instanced

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; // Need this for TRANSFORM_TEX macro
            StructuredBuffer<float4> positionBuffer; // Initialize pos buffer

            struct appdata
            {
                float2 uv : TEXCOORD0;
                float4 pos : POSITION;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v, uint instanceID : SV_InstanceID)
            {
                // Get position data from buffer for this instance
                float4 positionData = positionBuffer[instanceID];
                float3 localPosition = v.pos.xyz;
                float3 worldPosition = positionData.xyz + localPosition;

                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0f));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
