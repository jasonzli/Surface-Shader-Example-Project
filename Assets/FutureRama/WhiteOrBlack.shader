Shader "Custom/WhiteOrBlack"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Tex2 ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Threshold ("Threshold", Range(0,1)) = 0.8
        _WithLines("With Lines", Range(0,1)) = 0
        _LineSize ("Line Size", float) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Ramp

        sampler2D _Ramp;
        sampler2D _Tex2;
        sampler2D _MainTex;
        float _Threshold;
        float _LineSize;
        float _WithLines;

        half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten) {
            half NdotL = dot (s.Normal, lightDir);
            half diff = NdotL * 0.5 + 0.5;
            half3 ramp = tex2D (_Ramp, float2(diff, 0.)).rgb;
            half4 c;

            // !!!!!! BELOW IS WHAT I CHANGED (got this lighting model online)

            c.rgb =
                lerp(s.Albedo,
                    float3(1., 1., 1.) * 100.,
                    step(0.84, diff) * step(0.1, _WithLines))

                * _LightColor0.rgb 
                * ramp
                * atten
                * step(_Threshold, diff);
                c.a = s.Alpha;
            return c;
        }

        struct Input {
            float2 uv_MainTex;
        };
    
    
        void surf (Input IN, inout SurfaceOutput o) {
            
            fixed4 tex = tex2D (_Tex2, IN.uv_MainTex * _LineSize);
            float tex1 = step(1.0 * _WithLines, tex.x);

            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = float3(1., 1., 1.) * 100. * tex1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
