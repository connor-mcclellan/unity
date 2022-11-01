Shader "Instanced/RotatingSpriteShader"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _Angle ("Angle", float) = 0.0
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
            float _Angle;
            StructuredBuffer<float4> positionBuffer; // Initialize pos buffer

            struct appdata
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            float3x3 RotateAboutY(float th)
            {
                float thRadians = th * UNITY_PI / 180.0 * _Time.x;
                float sth, cth;
                sincos(thRadians, sth, cth);
                return float3x3(
                  cth,    0, -sth,
                    0,    1,    0,
                  sth,    0,  cth
                );
            }

            v2f vert (appdata v, uint instanceID : SV_InstanceID)
            {
                // Get position data from buffer for this instance
                float4 positionData = positionBuffer[instanceID];
                float3 localPosition = v.vertex.xyz;
                float3 worldPosition = positionData.xyz + localPosition;

                float3 pivot = worldPosition;

                worldPosition -= pivot;
                worldPosition = mul(RotateAboutY(_Angle), localPosition);
                worldPosition += pivot;

                v.vertex.xyz = worldPosition;

                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
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
