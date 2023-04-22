Shader "mccbc/PixelEdgeToonShader" {
    Properties {

        // Albedo from image texture
        _MainTex ("Diffuse", 2D) = "white" {}

        // Toon shader parameters
        _ShadowBands ("Shadow Bands", Int) = 3
        _ShadowOffset ("Shadow offset", Range (0, 3)) = 1
        _ShadowDarkness ("Shadow darkness", Range (0, 1)) = 1
        _ShadowTint ("Shadow tint", Color) = (0.0, 0.35, .65, 1)

        // TODO: Separate edge highlight for ambient lighting and individual light sources
        // Tune ambient to give subtle edge highlights to bring out geometry / pixel art style
        // Highlights from direct lights match light source color - warm glow from candle, green from potion, etc.
        
        // Pixel art edge highlight parameters
        _EdgeHighlightStrength ("Edge Highlight Strength", Range(0, 1)) = 0.5
        _EdgeShadowStrength ("Edge Shadow Strength", Range(0, 1)) = 0.5
        _UpWeight ("Up weight", Range(0, 1)) = 1.0
        _DownWeight ("Down weight", Range(0, 1)) = 0.0
        _LeftWeight ("Left weight", Range(0, 1)) = 0.5
        _RightWeight ("Right weight", Range(0, 1)) = 0.5

        // DEBUG PARAMETERS
        _NormalAngleThreshold ("Normal Angle Threshold", Range(0, 1)) = 0.5
        _NormalDepthThreshold ("Normal Depth Threshold", float) = 0.0005
        _DepthThreshold ("Depth Threshold", float) = 0.006

        // DEBUG VISUALIZER SELECTION
        _Rendered ("Render Mode", Int) = 1
        _DebugNormals ("Debug Normals", Int) = 0
        _DebugHighlights ("Debug Edge Highlights", Int) = 0
        _DebugShadows ("Debug Edge Shadows", Int) = 0
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _EdgeHighlightStrength;
            float _EdgeShadowStrength;
            int _ShadowBands;
            float _ShadowFalloff, _ShadowOffset, _ShadowDarkness;
            float4 _ShadowTint;
            float _NormalAngleThreshold, _NormalDepthThreshold;
            float _DepthThreshold;
            float _UpWeight, _DownWeight, _LeftWeight, _RightWeight; 
            int _Rendered, _DebugNormals, _DebugHighlights, _DebugShadows;

            struct appdata {
                float3 normal: NORMAL;
                float4 vertex: POSITION;
                float4 uv:TEXCOORD0;
            };

            struct v2f {
                float3 worldNormal : NORMAL;
                float4 pos : SV_POSITION;
                float4 objuv : TEXCOORD0;
                float4 screenuv: TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert (appdata v){
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal (v.normal);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.objuv = v.uv; // Object space UVs for albedo texture mapping
                o.screenuv = ComputeScreenPos(o.pos); // Screen-space UVs for pixel shader / edge highlights
                TRANSFER_SHADOW(o) // Macro to receive shadows from Autolight
                return o;
            }

            float2 neighborEdgeIndicator(sampler2D CamTexture, float2 uv, float2 dudv, float depth, float3 normal, float weight) {

                float neighborDepth;
                float3 neighborNormal;
                DecodeDepthNormal(tex2D(CamTexture, uv + dudv/_ScreenParams.xy), neighborDepth, neighborNormal);

                // TODO: Scale depth difference as a fraction of orthographic camera clipping planes?
                // Get mindepth and maxdepth from camera properties
                float ldepth = Linear01Depth(depth);
                float lneighborDepth = Linear01Depth(neighborDepth);
                float depthDiff = lneighborDepth - ldepth; // Positive if neighbor deeper than this pixel

                // Shallower pixel should detect the edge
                // If this pixel is shallower, depthDiff > 0 -> depthIndicator is 1
                // If neighbor pixel is shallower, depthDiff < 0 -> depthIndicator is 0
                float normalDepthIndicator = clamp(sign(depthDiff - _NormalDepthThreshold), 0.0, 1.0);

                // Separate threshold for whether or not to draw a shadow on this pixel
                float depthIndicator = clamp(sign(depthDiff - _DepthThreshold), 0.0, 1.0);

                // Detect edge if cosine of angle between adjacent pixels' normals is larger than threshold
                float normalDot = dot(normal, neighborNormal) / 1.73205; // divide by sqrt 3 so dot is between -1 and 1
                float normalAngle = 1 - normalDot;
                float normalIndicator = clamp(sign(normalAngle - _NormalAngleThreshold), 0.0, 1.0);

                // Pack depth and normal edge check values into a float2
                return float2(depthIndicator, weight * normalIndicator * normalDepthIndicator * (1-depthIndicator));
            }

            float2 neighborOld(sampler2D CamTexture, float2 uv, float2 dudv, float depth, float3 normal, float weight) {
 
                float neighborDepth;
                float3 neighborNormal;
                DecodeDepthNormal(tex2D(CamTexture, uv + dudv/_ScreenParams.xy), neighborDepth, neighborNormal);

                // TODO: Scale depth difference as a fraction of orthographic camera clipping planes?
                // Get mindepth and maxdepth from camera properties
                float ldepth = Linear01Depth(depth);
                float lneighborDepth = Linear01Depth(neighborDepth);
                float depthDiff = lneighborDepth - ldepth; // Positive if neighbor deeper than this pixel

                // Shallower pixel should detect the edge
                // If this pixel is shallower, depthDiff > 0 -> depthIndicator is 1
                // If neighbor pixel is shallower, depthDiff < 0 -> depthIndicator is 0
                float normalDepthIndicator = clamp(sign(depthDiff * .25 + 0.0025), 0.0, 1.0);

                // Separate threshold for whether or not to draw a shadow on this pixel
                float depthIndicator = depthDiff;

                // Detect edge if cosine of angle between adjacent pixels' normals is larger than threshold
                float normalDot = dot(normal - neighborNormal, float3(1, 1, 1)); // divide by sqrt 3 so dot is between -1 and 1
                float normalIndicator = clamp(smoothstep(-0.01, 0.01, normalDot), 0.0, 1.0);

                // Pack depth and normal edge check values into a float2
                return float2(depthIndicator, weight * (1 - dot(normal, neighborNormal)) * normalDepthIndicator * normalIndicator);
                
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
                float4 mainTexSample = tex2D(_MainTex, i.objuv);
                float4 shadowTint = (1 - lightIntensity) * _ShadowTint;

                // PIXEL EDGE HIGHLIGHTS AND DEPTH SHADOW
                // ======================================
                float depth;
                float3 norm;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.screenuv), depth, norm);

                float2 edgeIndicator = float2(0., 0.);
                edgeIndicator += neighborOld(_CameraDepthNormalsTexture, i.screenuv, float2(0,1), depth, norm, _UpWeight); //up
                edgeIndicator += neighborOld(_CameraDepthNormalsTexture, i.screenuv, float2(0,-1), depth, norm, _DownWeight); //down
                edgeIndicator += neighborOld(_CameraDepthNormalsTexture, i.screenuv, float2(-1,0), depth, norm, _LeftWeight); //left
                edgeIndicator += neighborOld(_CameraDepthNormalsTexture, i.screenuv, float2(1,0), depth, norm, _RightWeight); //right

                //float depthIndicator = clamp(edgeIndicator.x, 0.0, 1.0);
                float depthIndicator = floor(smoothstep(0.01, 0.02, edgeIndicator.x) * 2.0) / 2.0; // From three.js code
            	float normalIndicator = clamp(edgeIndicator.y, 0.0, 1.0);

                float highlight = _EdgeHighlightStrength * normalIndicator;
                float shadow = _EdgeShadowStrength * depthIndicator;

                float4 renderFrag = float4(mainTexSample.rgb * (lightIntensity + shadowTint.rgb) * (1 + highlight) * (1 - shadow), 1);
                float4 normalDebugFrag = float4(0.5 * norm + 0.5, 1);
                float4 highlightDebugFrag = float4(normalIndicator, normalIndicator, normalIndicator, 1);
                float4 shadowDebugFrag = float4(depthIndicator, depthIndicator, depthIndicator, 1);
                return renderFrag * _Rendered + normalDebugFrag * _DebugNormals + highlightDebugFrag * _DebugHighlights + shadowDebugFrag * _DebugShadows;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
