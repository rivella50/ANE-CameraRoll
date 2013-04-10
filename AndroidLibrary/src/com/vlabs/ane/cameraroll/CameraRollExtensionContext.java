package com.vlabs.ane.cameraroll;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.provider.MediaStore.Images;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.vlabs.ane.cameraroll.functions.CountPhotosFunction;
import com.vlabs.ane.cameraroll.functions.LoadPhotoAtIndexFunction;

public class CameraRollExtensionContext extends FREContext {

	public List<Images> assets;
	public Images currentAsset;
	
	@Override
	public void dispose() {

		assets = null;
		currentAsset = null;
		CameraRollExtension.context = null;
	}
	
	public void init() {
		
		assets = new ArrayList<Images>();
	}

	@Override
	public Map<String, FREFunction> getFunctions() {

		Map<String, FREFunction> map = new HashMap<String, FREFunction>();
		
		map.put("countPhotos", new CountPhotosFunction());
		map.put("loadPhotoAtIndex", new LoadPhotoAtIndexFunction());
		return map;
	}

}
