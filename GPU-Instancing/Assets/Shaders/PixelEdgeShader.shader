Shader "Custom/PixelEdgeShader" {
    Properties {
        _MainTex ("", 2D) = "white" {}
        _RenderTex ("Render Texture", 2D) = "white" {}
        _HighlightStrength ("Highlight Strength", Range(0, 1)) = 0
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
            sampler2D _MainTex;
            float _HighlightStrength;

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


            float3 neighborNormalEdgeIndicator(sampler2D CamTexture, float2 uv, float2 dudv, float depth, float3 normal) {
                float neighborDepth;
                float3 neighborNormal;
                DecodeDepthNormal(tex2D(CamTexture, uv + dudv/_ScreenParams.xy), neighborDepth, neighborNormal);

                float ldepth = Linear01Depth(depth);
                float lneighborDepth = Linear01Depth(neighborDepth);
                float depthDiff = lneighborDepth - ldepth;
                float depthIndicator = clamp(sign(depthDiff * .25 + .0025), 0.0, 1.0);

                float3 normalEdgeBias = float3(1., 1., 1.);
                float normalDiff = dot(normal - neighborNormal, normalEdgeBias);
                float normalIndicator = clamp(smoothstep(-.01, .01, normalDiff), 0.0, 1.0);

                return (1.0 - dot(normal, neighborNormal)) * depthIndicator * normalIndicator;
            }

            half4 frag (v2f i) : SV_Target{
                float depth;
                float3 norm;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, norm); // Center
                float edgeIndicator = 0.;
                edgeIndicator += neighborNormalEdgeIndicator(_CameraDepthNormalsTexture, i.uv, float2(0,1), depth, norm);
                edgeIndicator += neighborNormalEdgeIndicator(_CameraDepthNormalsTexture, i.uv, float2(0,-1), depth, norm);
                edgeIndicator += neighborNormalEdgeIndicator(_CameraDepthNormalsTexture, i.uv, float2(-1,0), depth, norm);
                edgeIndicator += neighborNormalEdgeIndicator(_CameraDepthNormalsTexture, i.uv, float2(1,0), depth, norm);
				float indicator = step(0.1, edgeIndicator);
                float highlight = _HighlightStrength * indicator;
                float4 Color = float4(norm * (1 + highlight), 1);
                return Color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}