package com.vlabs.ane.cameraroll.functions;

import android.content.ContentResolver;
import android.database.Cursor;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class CountPhotosFunction implements FREFunction {

	// http://stackoverflow.com/questions/4484158/list-all-camera-images-in-android
	public static final String CAMERA_IMAGE_BUCKET_NAME_DEFAULT = Environment.getExternalStorageDirectory().toString() + "/DCIM/Camera";
	public static final String CAMERA_IMAGE_BUCKET_NAME_HTC = Environment.getExternalStorageDirectory().toString() + "/DCIM/100MEDIA";
	
	public static final String CAMERA_IMAGE_BUCKET_ID_DEFAULT = getBucketId(CAMERA_IMAGE_BUCKET_NAME_DEFAULT);
	public static final String CAMERA_IMAGE_BUCKET_ID_HTC = getBucketId(CAMERA_IMAGE_BUCKET_NAME_HTC);
	
	/**
	 * Matches code in MediaProvider.computeBucketValues. Should be a common
	 * function.
	 */
	public static String getBucketId(String path) {
	    return String.valueOf(path.toLowerCase().hashCode());
	}
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		String[] projection = new String[]{
		        MediaStore.Images.Media._ID
		};

		Uri images = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
		final String selection = MediaStore.Images.Media.BUCKET_ID + " = ? OR " + MediaStore.Images.Media.BUCKET_ID + " = ?";
        final String[] selectionArgs = { CAMERA_IMAGE_BUCKET_ID_DEFAULT, CAMERA_IMAGE_BUCKET_ID_HTC };
		
		// Make the query.
		ContentResolver cr = context.getActivity().getContentResolver();
		Cursor cur = cr.query(images,
		        projection, // Which columns to return
		        selection,  // Which rows to return
		        selectionArgs,       // Selection arguments)
		        ""          // Ordering
		        );
		
		int count = cur.getCount();
		context.dispatchStatusEventAsync("countPhotosCompleted", (Integer.valueOf(count)).toString());
		return null;
	}

}
