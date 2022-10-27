Shader "mccbc/Toon" {
  Properties {
    _Color ("Color", Color) = (0.5, 0.65, 1, 1)
    _MainTex ("Main Texture", 2 D) = "white" {}
    _ShadowBands ("Shadow bands", Int) = 3
    _ShadowFalloff ("Shadow falloff", Range (0, 10)) = 0
    _ShadowOffset ("Shadow offset", Range (0, 3)) = 1
    _ShadowDarkness ("Shadow darkness", Range (0, 1)) = 1
    _ShadowTint ("Shadow tint", Color) = (0.0, 0.35, .65, 1)
    _RimWidth ("Rim width", Range (0, 1)) = 0
    _RimThreshold ("Rim threshold", Range (0, 1)) = 0
    _RimColor ("Rim color", Color) = (1, 1, 1, 1)
    _BoundarySmoothing ("Boundary Smoothing", Range (0, 1) = 0.01
  }
  SubShader {
    Pass {
	    Tags {
		    "LightMode" = "ForwardBase"
		    "PassFlags" = "OnlyDirectional"
      }

	    CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_fwdbase
      #include "UnityCG.cginc"
      #include "AutoLight.cginc"

	    struct appdata {
        float3 normal: NORMAL;
        float4 vertex: POSITION;
        float4 uv:TEXCOORD0;
      };

	    struct v2f {
        float3 worldNormal: NORMAL; 
        float3 viewDir: TEXCOORD1; 
        float4 pos: SV_POSITION; 
        float2 uv:TEXCOORD0;
	      SHADOW_COORDS (2)
      };

      sampler2D _MainTex;
	    float4 _MainTex_ST;

      v2f vert (appdata v) {
	      v2f o;
	      o.worldNormal = UnityObjectToWorldNormal (v.normal);
	      o.viewDir = WorldSpaceViewDir (v.vertex);
	      o.pos = UnityObjectToClipPos (v.vertex);
	      o.uv = TRANSFORM_TEX (v.uv, _MainTex);
	      TRANSFER_SHADOW (o) 
        return o;
      }

      int _ShadowBands;
      float _ShadowFalloff, _ShadowOffset, _ShadowDarkness, _RimWidth; 
            _RimThreshold;
      float4 _Color, _ShadowTint, _RimColor; 

      float4 frag (v2f i):SV_Target {
	      float3 normal = normalize (i.worldNormal);
	      float NdotL = dot (_WorldSpaceLightPos0, normal);
	      float3 viewDir = normalize (i.viewDir);

	      // Normalize NdotL to a value between 0 and 1
	      float NdotLNorm = 0.5 * (NdotL + 1);

	      // Calculate light intensity based on shadow falloff
	      float lightIntensity = 1 - exp (-NdotLNorm * _ShadowFalloff + 
                               _ShadowOffset) * (1 - NdotLNorm);

	      // Compute shadow attenuation
	      float shadow = SHADOW_ATTENUATION (i);
	      lightIntensity *= shadow;

	      // Clamp intensity to discrete bands
	      float bandedIntensity = ceil (lightIntensity * _ShadowBands) 
                                / _ShadowBands;

	      // Rescale intensity according to how dark shadows should be
	      bandedIntensity = lerp (1 - _ShadowDarkness, 1, bandedIntensity);
	      float clampedIntensity = clamp (bandedIntensity, 
                                        1 - _ShadowDarkness, 1);
	      float4 sample = tex2D (_MainTex, i.uv);

	      // Calculate shadow tint
	      float4 shadowTint = (1 - clampedIntensity) * _ShadowTint;

	      // Calculate rim lighting
	      float4 rimDot = 1 - dot (viewDir, normal);
	      float rimIntensity = round (rimDot * pow (NdotLNorm, _RimThreshold) *
                                    _RimWidth);
	      float4 rim = rimIntensity * _RimColor;
	      return _Color * sample * (clampedIntensity + shadowTint + rim);
      } // end frag
	    ENDCG
    } // end main pass
    UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
  } // end subshader
} // end shader
