﻿Shader "Unlit/CenterMonitor"
{
   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ChannelSwap("ChannelSwap", RAnge(0.4, 0.6)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Blend One OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define PI 3.141592
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ChannelSwap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                half angle = 0.75 * PI * 2; \
                half angleCos = cos(angle);
                half angleSin = sin(angle);
                half2x2 rotateUV = half2x2(angleCos, -angleSin, angleSin, angleCos);//回転行列作成
                float monitorSize = 540 / 1280.0;
                float monitorSizeWithBlack20 = 425.0 / 1280.0;
                i.uv.x = i.uv.x; //縦二枚に分割するのでx方向についてはそのまま
                _ChannelSwap = step(0.5, _ChannelSwap);
                i.uv.y =i.uv.y * monitorSize; //+ monitorSizeWithBlack20 * step(1.0,_ChannelSwap);
                i.uv = mul(i.uv - 0.5, rotateUV) + 0.5; //参照範囲を決定したうえで回転行列によって回転(-0.5しているのは原点中心に回転させるため。+0.5で回転後にuv座標がもとに位置に戻るよう修正)
                
                fixed4 col = tex2D(_MainTex, i.uv);
                col.a = 0.5;
                //fixed luminance = (0.2126 * col.r + 0.7152 * col.g + 0.072 * col.b);
                //col.a = luminance;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}