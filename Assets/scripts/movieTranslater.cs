using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class movieTranslater : MonoBehaviour
{
    public RenderTexture renderTextureFromVideo;
    private Texture2D textureForShader;
    public Material monitor01;
    public Material monitor02;
    public Material monitor03;
 
    void Start()
    {
        textureForShader = new Texture2D(renderTextureFromVideo.width,renderTextureFromVideo.height, TextureFormat.RGB24, false);//テクスチャの初期化
    }
    void Update()
    {  
        if(renderTextureFromVideo != null)//一応
        {
            TranslateRenderTex();
            monitor01.SetTexture("_MainTex",textureForShader);
            monitor02.SetTexture("_MainTex", textureForShader);
            monitor03.SetTexture("_MainTex", textureForShader);
        }
    }

    void TranslateRenderTex()
    {
        RenderTexture.active = renderTextureFromVideo;
        textureForShader.ReadPixels(new Rect(0,0, renderTextureFromVideo.width, renderTextureFromVideo.height), 0,0);
        textureForShader.Apply();
    }
}
