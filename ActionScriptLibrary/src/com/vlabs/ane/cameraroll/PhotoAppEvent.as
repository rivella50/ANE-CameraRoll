package com.vlabs.ane.cameraroll
{
	import flash.events.Event;
	
	public class PhotoAppEvent extends Event
	{
		public var data:Object;
		
		public static const type:String = "PHOTO_APP_EVENT";
		public static const EVENT_COUNT_PHOTOS:String = "eventCountPhotos";
		public static const EVENT_THUMBS_LOADED:String = "eventThumbsLoaded";
		public static const EVENT_FULLSCREEN_IMAGE_LOADED:String = "eventFullscreenImageLoaded";
		
		public function PhotoAppEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}