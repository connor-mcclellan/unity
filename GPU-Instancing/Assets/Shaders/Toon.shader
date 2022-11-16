Shader "mccbc/Toon" {
  Properties {
    _Color ("Color", Color) = (0.5, 0.65, 1, 1)
    _MainTex ("Main Texture", 2D) = "white" {}
    _ShadowBands ("Shadow bands", Int) = 3
    _ShadowOffset ("Shadow offset", Range (0, 3)) = 1
    _ShadowDarkness ("Shadow darkness", Range (0, 1)) = 1
    _ShadowTint ("Shadow tint", Color) = (0.0, 0.35, .65, 1)
  }
  SubShader {
    Tags {
      "RenderType" = "Opaque"
      "LightMode" = "ForwardBase"
      "PassFlags" = "OnlyDirectional"
    }
    Pass {
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
        float4 pos: SV_POSITION;
        float2 uv:TEXCOORD0;
	      SHADOW_COORDS (2)
      };

      sampler2D _MainTex;
	    float4 _MainTex_ST;

      v2f vert (appdata v) {
	      v2f o;
	      o.worldNormal = UnityObjectToWorldNormal (v.normal);
	      o.pos = UnityObjectToClipPos (v.vertex);
	      o.uv = TRANSFORM_TEX (v.uv, _MainTex);
	      TRANSFER_SHADOW (o)
        return o;
      }

      int _ShadowBands;
      float _ShadowFalloff, _ShadowOffset, _ShadowDarkness;
      float4 _Color, _ShadowTint;

      float4 frag (v2f i):SV_Target {
	      float3 normal = normalize (i.worldNormal);
	      float NdotL = dot (_WorldSpaceLightPos0, normal);

	      // Normalize NdotL to a value between 0 and 1
	      float NdotLNorm = 0.5 * (NdotL + 1);

	      // Calculate light intensity based on shadow falloff
	      float lightIntensity = 1 - exp (-NdotLNorm +
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

	      return _Color * sample * (clampedIntensity + shadowTint);
      } // end frag
	    ENDCG
    } // end main pass
    UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
  } // end subshader
} // end shader
