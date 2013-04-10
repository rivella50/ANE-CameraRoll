package com.vlabs.ane.cameraroll;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class CameraRollExtension implements FREExtension {

	
	public static CameraRollExtensionContext context;
	
	@Override
	public FREContext createContext(String arg0) {

		return context = new CameraRollExtensionContext();
	}

	@Override
	public void dispose() {

		context = null;	
	}

	@Override
	public void initialize() {

		context.init();
	}

}
