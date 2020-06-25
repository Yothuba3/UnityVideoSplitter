Shader "Unlit/CenterMonitor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Alpha("透明度", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Blend  One OneMinusSrcAlpha
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
            fixed _Alpha;

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
                half2x2 rotateUV = half2x2(0, 1 , -1, 0);  //回転行列作成(270度回転)
                float monitorSize = 0.421875;              //映像一つの解像度 / 合成した映像の解像度
                float monitorSizeWithBlack = 0.578125; //スキップしたい映像一つの解像度(黒帯つき) / 合成した映像の解像度
                
                i.uv = mul(i.uv - 0.5, rotateUV) + 0.5; //回転行列によって回転(-0.5しているのは原点中心に回転させるため。+0.5で回転後にuv座標がもとに位置に戻るよう修正)
                i.uv.x = i.uv.x * monitorSize + monitorSizeWithBlack; 
                i.uv.y =i.uv.y; 
                
                fixed4 col = tex2D(_MainTex, i.uv);
                col.a = _Alpha;  //透明度変更
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
