Shader "Unlit/MirrorMonitor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #define PI 3.141592
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

            //動画上に反転フラグが存在するかどうか(仮置き)
            fixed isSwap(half2x2 rotateUV)
            {
                float2 uvForInverseSystem = float2(0.092, 0.75);   //仮のUV値 ちょうど左の黒帯の上半分のど真ん中あたり
                return step(0.5,  tex2D(_MainTex, uvForInverseSystem).r); //rgbのrの値をフラグとして扱う(仮)
            }

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
                float monitorSize02 = 0.31640625;          //取得したい映像の解像度 / 全体の映像の解像度
                float skipSize =  0.18359375;             //スキップしたい部分の解像度 / 全体の映像の解像度
                
                i.uv = mul(i.uv - 0.5, rotateUV) + 0.5; //回転行列によって回転(-0.5しているのは原点中心に回転させるため。+0.5で回転後にuv座標がもとに位置に戻るよう修正)
                //映像の取得範囲指定
                i.uv.x = i.uv.x * monitorSize02 + skipSize; 
                i.uv.y = 1.0 - i.uv.y - (isSwap(rotateUV) * (1.0 - i.uv.y - i.uv.y ));
                fixed4 col = tex2D(_MainTex, i.uv);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
