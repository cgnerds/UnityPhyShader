﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof (Camera))]
[ExecuteInEditMode]

public class PostEffects : MonoBehaviour {

	public Shader curShader;
	private Material curMaterial;
	[Range(1.0f, 10.0f)]
	public float ToneMapperExposure = 2.0f;
	public bool InvertEffect;
	public bool DepthEffect;
	public bool LinearInvertEffect;
	public bool ToneMappingEffect;

	Material material
	{
		get
		{
			if(curMaterial == null) 
			{
				curMaterial = new Material(curShader);
				curMaterial.hideFlags = HideFlags.HideAndDontSave;
			}
			return curMaterial;
		}
	}

	// Use this for initialization
	void Start () {
		curShader = Shader.Find("Hidden/PostEffects");
		GetComponent<Camera>().allowHDR = true;
		if(!SystemInfo.supportsImageEffects) {
			enabled = false;
			Debug.Log("Not Supported");
			return;
		}
		if(!curShader && !curShader.isSupported) {
			enabled = false;
			Debug.Log("Not Supported");
		}
		GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
	}

	void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
	{
		if(curShader != null)
		{
			Graphics.Blit(sourceTexture, destTexture, material, 0);
			if(InvertEffect) {
		        Graphics.Blit(sourceTexture, destTexture, material, 0);
			} else if(DepthEffect) {
		        Graphics.Blit(sourceTexture, destTexture, material, 1);
			}
		}
		// } else if(DepthEffect) {
		// } else if(LinearInvertEffect) {
		// 	Graphics.Blit(sourceTexture, destTexture, material, 2);
		// } else if(ToneMappingEffect) {
		// 	material.SetFloat("_ToneMapperExposure", ToneMapperExposure);
		// 	Graphics.Blit(sourceTexture, destTexture, material, 3);
		// } else {
		// 	Graphics.Blit(sourceTexture, destTexture);
		// }
	}
	
	// Update is called once per frame
	void Update () {
		if(!GetComponent<Camera>().enabled)
		    return;
	}

	void OnDisable() {
		if(curMaterial){
			DestroyImmediate(curMaterial);
		}
	}
}
