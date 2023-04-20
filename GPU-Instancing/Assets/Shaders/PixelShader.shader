Shader "mccbc/PixelEdgeToonShader" {
    Properties {
        _MainTex ("", 2D) = "white" {}
        _Color ("Color", Color) = (0.5, 0.5, 0.5, 1)
        _ShadowBands ("Shadow Bands", Int) = 3
        _ShadowOffset ("Shadow offset", Range (0, 3)) = 1
        _ShadowDarkness ("Shadow darkness", Range (0, 1)) = 1
        _ShadowTint ("Shadow tint", Color) = (0.0, 0.35, .65, 1)
        _EdgeHighlightStrength ("Highlight Strength", Range(0, 1)) = 0.5
        _EdgeShadowStrength ("Shadow Strength", Range(0, 1)) = 0.5
    }

    SubShader {
        Tags {
            "RenderType"="Opaque"
            "LightMode"="ForwardBase"
            "PassFlags"="OnlyDirectional"
        }

        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            // *Must* set GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals
            // in CameraController script - tells Camera to render depth and normals textures
            sampler2D _CameraDepthNormalsTexture;
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _EdgeHighlightStrength;
            float _EdgeShadowStrength;
            int _ShadowBands;
            float _ShadowFalloff, _ShadowOffset, _ShadowDarkness;
            float4 _ShadowTint;

            struct appdata {
                float3 normal: NORMAL;
                float4 vertex: POSITION;
                float4 uv:TEXCOORD0;
            };

            struct v2f {
                float3 worldNormal : NORMAL;
                float4 pos : SV_POSITION;
                float4 uv: TEXCOORD0;
                SHADOW_COORDS(2)
            };

            v2f vert (appdata v){
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal (v.normal);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv=ComputeScreenPos(o.pos);
                TRANSFER_SHADOW(o)
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

                // TOON SHADER - Currently supports only one light source
                // ======================================================
                float3 normal = normalize(i.worldNormal);
                float NdotL = dot(_WorldSpaceLightPos0, normal);
                float NdotLNorm = 0.5 * (NdotL + 1);

                // Exponential falloff in light intensity
                float lightIntensity = 1 - exp(-NdotLNorm + _ShadowOffset) * (1 - NdotLNorm);

                // Shadow attenuation
                float toonShadow = SHADOW_ATTENUATION(i);
                lightIntensity *= toonShadow;

                // Clamp intensity to discrete bands
                lightIntensity = ceil(lightIntensity * _ShadowBands) / _ShadowBands;

                // Rescale to bottom out according to toon shadow darkness parameter
                lightIntensity = lerp(1-_ShadowDarkness, 1, lightIntensity);
                lightIntensity = clamp(lightIntensity, 1-_ShadowDarkness, 1);
                float4 mainTexSample = tex2D(_MainTex, i.uv);
                float4 shadowTint = (1 - lightIntensity) * _ShadowTint;


                // PIXEL EDGE HIGHLIGHTS AND DEPTH SHADOW
                // ======================================
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

                float highlight = _EdgeHighlightStrength * normalIndicator;
                float shadow = _EdgeShadowStrength * depthIndicator;


                return float4(_Color.rgb * (lightIntensity + shadowTint.rgb) * (1 + highlight) * (1 - shadow), 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
