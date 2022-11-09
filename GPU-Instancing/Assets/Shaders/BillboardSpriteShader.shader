Shader "Instanced/BillboardSpriteShader"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
          //"DisableBatching"="True"
          "Queue"="Transparent" 
        } // Render to the transparent queue
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
            StructuredBuffer<float4> positionBuffer;

            struct appdata
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Simple billboard vertex shader
            // Reference: https://www.youtube.com/watch?v=qGppGvgw7Dg
            v2f vert (appdata v, uint instanceID : SV_InstanceID)
            {
                v2f o;

                // Get position data from buffer for this instance
                float4 positionData = positionBuffer[instanceID];

                // Origin of the object in world space
                float4 worldOrigin = mul(UNITY_MATRIX_M, float4(positionData.xyz, 1));

                // Origin of the object in view space
                float4 viewOrigin = float4(UnityObjectToViewPos(positionData.xyz), 1);

                // Local position of object
                float4 localPos = float4(v.vertex.xyz + positionData.xyz, 1.);

                // Deconstruct the calls to render the vertex to clip space
                float4 worldPos = mul(UNITY_MATRIX_M, localPos); // Model matrix
                float4 viewPos = worldPos - worldOrigin + viewOrigin; // View matrix
                float4 clipPos = mul(UNITY_MATRIX_P, viewPos); // Perspective matrix

                o.uv = v.uv.xy;
                o.vertex = clipPos;
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
