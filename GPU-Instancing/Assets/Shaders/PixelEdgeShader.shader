Shader "Custom/PixelEdgeShader" {
    Properties {
        _MainTex ("", 2D) = "white" {}
        _Color ("Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _HighlightStrength ("Highlight Strength", Range(0, 1)) = 0.5
        _ShadowStrength ("Shadow Strength", Range(0, 1)) = 0.5
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
            float _ShadowStrength;
            float4 _Color;

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


            float2 neighborEdgeIndicator(sampler2D CamTexture, float2 uv, float2 dudv, float depth, float3 normal) {
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

                // Pack depth and normal edge check values into a float2
                float depthValue = clamp(depthDiff, 0., 1.);
                float normValue = (1.0 - dot(normal, neighborNormal)) * depthIndicator * normalIndicator;
                return float2(depthValue, normValue);
            }

            half4 frag (v2f i) : SV_Target{

                float depth;
                float3 norm;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, norm);

                float2 edgeIndicator = float2(0., 0.);
                edgeIndicator += neighborEdgeIndicator(_CameraDepthNormalsTexture, i.uv, float2(0,1), depth, norm);
                edgeIndicator += neighborEdgeIndicator(_CameraDepthNormalsTexture, i.uv, float2(0,-1), depth, norm);
                edgeIndicator += neighborEdgeIndicator(_CameraDepthNormalsTexture, i.uv, float2(-1,0), depth, norm);
                edgeIndicator += neighborEdgeIndicator(_CameraDepthNormalsTexture, i.uv, float2(1,0), depth, norm);

                float depthIndicator = floor(smoothstep(0.01, 0.02, edgeIndicator.x) * 2.) / 2.;
				float normalIndicator = step(0.1, edgeIndicator.y);

                float highlight = _HighlightStrength * normalIndicator;
                float shadow = _ShadowStrength * depthIndicator;

                return float4(_Color.rgb * (1 + highlight) * (1 - shadow), 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}