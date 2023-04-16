Shader "Custom/PixelEdgeShader" {
    Properties {
        _MainTex ("", 2D) = "white" {}
        _RenderTex ("Render Texture", 2D) = "white" {}
    }

    SubShader {
        Tags {"RenderType"="Opaque"}

        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // NOTE: *Must* set GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals
            // in CameraController script - tells Camera to render depth and normals textures
            sampler2D _CameraDepthNormalsTexture;
            sampler2D _RenderTex;
            float4 _RenderTex_TexelSize;

            struct appdata {
                float4 vertex: POSITION;
                float4 uv:TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 uv: TEXCOORD0;
            };

            v2f vert (appdata v){
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv=ComputeScreenPos(o.vertex);
                return o;
            }

            sampler2D _MainTex;

            half4 frag (v2f i) : SV_Target{
                float3 normalValues;
                float depthValue;
                float2 pixelScale = _RenderTex_TexelSize.zw / _ScreenParams.xy;
                float2 pixelUV = floor(i.uv * pixelScale + 0.5) / pixelScale;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, pixelUV), depthValue, normalValues);
                // TODO: Perform normal sampling for pixelUV +- 1 from this coordinate in all 4 directions
                // If difference is greater than threshold, apply the highlight to the base color
                // Make sure only upward-facing normals in world coordinates are highlighted
                // (with locked isometric camera, can just use green-valued normals as potential highlight locations?)
                float4 normalColor = float4(normalValues, 1);
                return normalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}