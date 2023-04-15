Shader "Custom/PixelShader" {
    Properties {
        _MainTex ("", 2D) = "white" {}
    }

    SubShader {
        Tags { "RenderType"="Opaque"}

        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // NOTE: *Must* set GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals
            // in CameraController script - tells Camera to render depth and normals textures
            sampler2D _CameraDepthNormalsTexture;

            struct appdata {
                float4 vertex: POSITION;
                float4 uv:TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 uv: TEXCOORD0;
            };

            //Our Vertex Shader
            v2f vert (appdata v){
                v2f o;
                o.vertex = UnityObjectToClipPos (v.vertex);
                o.uv=ComputeScreenPos(o.vertex);
                return o;
            }

            sampler2D _MainTex;

            half4 frag (v2f i) : SV_Target{
                float3 normalValues;
                float depthValue;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depthValue, normalValues);
                float4 normalColor = float4(normalValues, 1);
                return normalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}