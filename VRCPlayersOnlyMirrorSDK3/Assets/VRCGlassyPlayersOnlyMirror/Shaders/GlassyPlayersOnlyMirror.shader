Shader "Mirror/VRCGlassyPlayersOnlyMirror"
{
    Properties
    { 
        _MainTex("Base (RGB)", 2D) = "white" {}
        [HideInInspector] _ReflectionTex0("", 2D) = "white" {}
        [HideInInspector] _ReflectionTex1("", 2D) = "white" {}
        [Toggle] _HideBackground("Hide Background", Float) = 0
        [Toggle] _IgnoreEffects("Ignore Effects", Float) = 0
        [Toggle] _CutOut("CutOut Mode", Float) = 0
        _Transparency("Transparency", Range(0, 1)) = 1

        [Header(NonCutOut OnlySettings)]
        _TransparencyTex("Transparency Mask", 2D) = "white" {}
        _DistanceFade("Distance Fade", Range(0,20)) = 0
        _DistanceFadeLength("Distance Fade Length", Range(0,10)) = 1
        [Toggle] _SmoothEdge("Smooth Edge", Float) = 1
        _AlphaTweakLevel("Alpha Tweak Level", Range(0,1)) = 0.75
        //Stencils
        [Header(Stencil Settings)]
        _Stencil ("Stencil ID", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompareAction ("Stencil Compare Function", int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Pass Operation", int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Stencil Fail Operation", int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("Stencil ZFail Operation", int) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        //BlendMode
    
        [Header(RenderingTweak)]
        [ToggleUI] _ZWrite("Z Write", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcFactor("SrcFactor", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstFactor("DstFactor", Float) = 0
        [Toggle] _PreMult("Pre-Multiply Alpha", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp("BlendOp", Float) = 0
    }
    SubShader
    {
        Tags{ "RenderType"="Transparent" "Queue"="Transparent+1" "IgnoreProjector"="True"}
        ZWrite [_ZWrite]
        BlendOp [_BlendOp], Add
        AlphaToMask Off//[_CutOut]
        Blend [_SrcFactor] [_DstFactor], One One
        LOD 100

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilCompareAction]
            Pass [_StencilOp]
            Fail [_StencilFail]
            ZFail [_StencilZFail]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
            #include "UnityInstancing.cginc"

            #pragma multi_compile_local _ _SMOOTHEDGE_ON
            #pragma multi_compile_local _ _HIDEBACKGROUND_ON
            #pragma multi_compile_local _ _IGNOREEFFECTS_ON
            #pragma multi_compile_local _ _PREMULT_ON
            #pragma multi_compile_local _ _CUTOUT_ON

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Transparency;
            float _DistanceFade;
            float _DistanceFadeLength;
            float _AlphaTweakLevel;

            sampler2D _ReflectionTex0;
            sampler2D _ReflectionTex1;
            sampler2D _TransparencyTex;

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 refl : TEXCOORD1;
                float4 pos : SV_POSITION;
                float4 distance : TEXCOORD2;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            struct Input {
                float2 _ReflectionTex0;
                float2 _ReflectionTex1;
                float2 _TransparencyTex;
            };

            v2f vert(appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.refl = ComputeNonStereoScreenPos(o.pos);

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                half4 tex = tex2D(_MainTex, i.uv);
                half4 trans = tex2D(_TransparencyTex, i.uv);
                half4 refl = unity_StereoEyeIndex == 0 ? tex2Dproj(_ReflectionTex0, UNITY_PROJ_COORD(i.refl)) : tex2Dproj(_ReflectionTex1, UNITY_PROJ_COORD(i.refl));

                // Hiding background
                #ifdef _HIDEBACKGROUND_ON
                    #ifndef _IGNOREEFFECTS_ON
                        half power = dot(refl.rgb, fixed3(1,1,1)) / 3;
                        bool applyIgnoreEffects = power > 0.01;
                    #endif
                    
                    #ifdef _CUTOUT_ON
                        #ifndef _IGNOREEFFECTS_ON
                            refl.a = refl.a > 0 ? 1 : (applyIgnoreEffects ? 1 : 0);
                        #else
                        refl.a = refl.a > 0 ? 1 : 0;
                        #endif
                        clip(refl.a);
                    #else
                        #ifdef _SMOOTHEDGE_ON
                            #ifndef _IGNOREEFFECTS_ON
                                refl.a = refl.a > 0 ? refl.a : (applyIgnoreEffects ? power : 0);
                            #else
                                refl.a = refl.a > 0 ? refl.a : 0;
                            #endif
                            refl.a = smoothstep(0, _AlphaTweakLevel, refl.a);
                        #else
                            #ifndef _IGNOREEFFECTS_ON
                                refl.a = refl.a > 0 ? 1 : (applyIgnoreEffects ? 1 : 0);
                            #else
                                refl.a = refl.a > 0 ? 1 : 0;
                            #endif
                        #endif
                    #endif
                #else
                    refl.a = 1;
                #endif

                #ifndef _CUTOUT_ON
                    // distance fade
                    if (_DistanceFade > 0) {
                        refl.a *= 1 - smoothstep(_DistanceFade, _DistanceFade + _DistanceFadeLength, distance(i.distance, mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0))));
                    }
                #endif
                refl *= tex;
                
                    refl.a *= dot(trans.rgb, fixed3(1,1,1)) / 3; // render texture transparency override 
                    refl.a *= (1 - _Transparency); // slider transparency
                    #ifdef _PREMULT_ON
                        refl.rgb *= refl.a; //pre-multiply alpha
                    #endif
                return refl;
            }

            ENDCG
        }
    }
}
