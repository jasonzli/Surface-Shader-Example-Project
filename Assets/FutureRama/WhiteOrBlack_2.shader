// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/WhiteOrBlack2"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Tex2 ("Line Texture", 2D) = "white" {}
        _ScreenTex ("Screen Texture", 2D) = "white" { }
        _Threshold ("Threshold", Range(0,1)) = 0.8
        _WithLines("With Lines", Range(0,1)) = 0
        _LineSize ("Line Size", float) = 10
    }
    SubShader
    {
        Pass {}
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Ramp fullforwardShadows

        sampler2D _Tex2;
        sampler2D _ScreenTex;
        float _Threshold;
        float _LineSize;
        float _WithLines;
        float4 _Tex2_ST;

        half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten) {
            half NdotL = dot (s.Normal, lightDir);
            half diff = NdotL * 0.5 + 0.5;
            half4 c;

            // !!!!!! BELOW IS WHAT I CHANGED (got this lighting model online)

            c.rgb = s.Albedo * _LightColor0.rgb * atten * step(_Threshold,pow(diff,1.25));
            c.a = s.Alpha* step(_Threshold,diff);
            return c;
        }

        struct Input {
            float2 uv_MainTex;
            float4 screenPos;
        };
    
        sampler2D _MainTex;
    
        #define HASHSCALE1 (443.8975)
        #define HASHSCALE3 float3(443.897, 441.423, 437.195)
        #define HASHSCALE4 float4(443.897, 441.423, 437.195, 444.129)

        
        inline float2 hash23(float3 p3)
        {
	        p3 = frac(p3 * HASHSCALE3);
	        p3 += dot(p3, p3.yzx + 19.19);
	        return frac((p3.xx + p3.yz)*p3.zy);
        }

        void surf (Input IN, inout SurfaceOutput o) {

            //Get Object world position
            float3 baseWorldPos = mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz;
    
            float2 textureCoordinate = IN.screenPos.xy / IN.screenPos.w;
            float aspect = _ScreenParams.x / _ScreenParams.y;
            
            textureCoordinate.x = textureCoordinate.x * aspect;
            textureCoordinate = TRANSFORM_TEX(textureCoordinate, _Tex2);

            fixed4 tex = tex2D (_Tex2, textureCoordinate * (_LineSize + (hash23(baseWorldPos).x-.5)*.5) +
                hash23(baseWorldPos) * 23.49f);
            
            o.Albedo = tex.rgb;

            
        }
        ENDCG
 // Outline attempt
        Pass
        {
            Name "Outline"
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
            
                struct v2f {
                    float4 pos: POSITION;
                    float3 normal : NORMAL;
                    float4 screenPos: TEXCOORD0;
                };

                v2f vert (appdata_full v)
                {
                    v2f o;
                    v.vertex.xyz += v.normal * .01;
                    o.pos = UnityObjectToClipPos(v.vertex);   
                    o.screenPos = ComputeScreenPos(o.pos);
                    return o;
                }

                float4 frag( v2f i ) : COLOR
                {
                    return float4(1.,1.,1., 1.0);
                }
            ENDCG      
        }
    }
    FallBack "Diffuse"
}
