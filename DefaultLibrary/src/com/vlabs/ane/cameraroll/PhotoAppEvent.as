package com.vlabs.ane.cameraroll
{
	import flash.events.Event;
	
	public class PhotoAppEvent extends Event
	{
		public var data:Object;
		
		public static const type:String = "PHOTO_APP_EVENT";
		public static const EVENT_COUNT_PHOTOS:String = "eventCountPhotos";
		public static const EVENT_THUMBS_LOADED:String = "eventThumbsLoaded";
		public static const EVENT_THUMBS_FOR_URLS_LOADED:String = "eventThumbsForUrlsLoaded";
		
		public static const EVENT_THUMBNAIL_IMAGE_LOADED:String = "eventThumbnailImageLoaded";
		public static const EVENT_THUMBNAIL_IMAGE_NOT_LOADED:String = "eventThumbnailImageNotLoaded";
		
		public static const EVENT_FULL_SCREEN_IMAGE_LOADED:String = "eventFullScreenImageLoaded";
		public static const EVENT_FULL_SCREEN_IMAGE_NOT_LOADED:String = "eventFullScreenImageNotLoaded";
		
		public static const EVENT_FULL_RESOLUTION_IMAGE_LOADED:String = "eventFullResolutionImageLoaded";
		public static const EVENT_FULL_RESOLUTION_IMAGE_NOT_LOADED:String = "eventFullResolutionImageNotLoaded";
		
		public static const EVENT_DEFAULT_THUMBNAIL_DIMENSIONS_LOADED:String = "eventDefaultThumbnailDimensionsLoaded";
		public static const EVENT_DEFAULT_THUMBNAIL_DIMENSIONS_NOT_LOADED:String = "eventDefaultThumbnailDimensionsNotLoaded";
		
		public function PhotoAppEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}