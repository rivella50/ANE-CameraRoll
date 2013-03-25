package com.vlabs.ane.cameraroll
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	
	public class CameraRollExtension extends EventDispatcher
	{
		private static const LOAD_PHOTO_TYPE_THUMBNAILS:String = "loadPhotoTypeThumbnails";
		private static const LOAD_PHOTO_TYPE_THUMBNAILS_FOR_URLS:String = "loadPhotoTypeThumbnailsForUrls";
		
		private static const LOAD_PHOTO_TYPE_THUMBNAIL:String = "loadPhotoTypeThumbnail";
		private static const LOAD_PHOTO_TYPE_ASPECT_RATIO_THUMBNAIL:String = "loadPhotoTypeAspectRatioThumbnail";
		private static const LOAD_PHOTO_TYPE_FULL_SCREEN:String = "loadPhotoTypeFullScreen";
		private static const LOAD_PHOTO_TYPE_FULL_RESOLUTION:String = "loadPhotoTypeFullResolution";
		
		private static const LOAD_PHOTO_TYPE_THUMBNAIL_FOR_DIMENSIONS:String = "loadPhotoTypeThumbnailForDimensions";
		
		private static const PHOTO_TYPE_THUMBNAIL:String = "thumbnail";
		private static const PHOTO_TYPE_ASPECT_RATIO_THUMBNAIL:String = "aspectRatioThumbnail";
		private static const PHOTO_TYPE_FULL_SCREEN:String = "fullScreen";
		private static const PHOTO_TYPE_FULL_RESOLUTION:String = "fullResolution";
		
		private static const COUNT_PHOTOS_COMPLETED:String = "countPhotosCompleted";
		
		private static var _instance:CameraRollExtension;
				
		
		public function CameraRollExtension()
		{
		}
		
		public static function getInstance() : CameraRollExtension
		{
			return _instance ? _instance : new CameraRollExtension();
		}
		
		public static function get isSupported():Boolean
		{
			return false;
		}
		
		//
		// API
		//
		
		public function initNativeCode():void {
			
		}
		
		public function determineThumbnailDefaultDimensions():void {
		
			var dimensions:PhotoDimensions = new PhotoDimensions();
			dimensions.width = 150;
			dimensions.height = 150;
			var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_DEFAULT_THUMBNAIL_DIMENSIONS_LOADED);
			event.data = dimensions;
			dispatchEvent(event);
		}
		
		public function countPhotos():void {
			
			var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_COUNT_PHOTOS);
			event.data = "0";
			dispatchEvent(event);
		}
		
		public function loadThumbnailPhotoAssets(startIndex:int, amount:int, type:String = LOAD_PHOTO_TYPE_THUMBNAILS):void {
			
			var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_THUMBS_LOADED);
			event.data = [];
			dispatchEvent(event);
		}
		
		public function loadThumbnailPhotoAssetsForUrls(urls:Array, type:String = LOAD_PHOTO_TYPE_THUMBNAILS_FOR_URLS):void {
			
			var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_THUMBS_FOR_URLS_LOADED);
			event.data = [];
			dispatchEvent(event);
		}
		
		public function getPhotoInfos(startIndex:int, length:int):Array {
			
			return [];
		}
		
		
		public function getCurrentPhotoInfo():PhotoMetadata {
			
			return null;
		}
		
		public function loadThumbnailPhotoForUrl(url:String, type:String = LOAD_PHOTO_TYPE_THUMBNAIL):void {
			
		}
		
		public function loadFullScreenPhotoForUrl(url:String, type:String = LOAD_PHOTO_TYPE_FULL_SCREEN):void {
			
		}
		
		public function loadFullResolutionPhotoForUrl(url:String, type:String = LOAD_PHOTO_TYPE_FULL_RESOLUTION):void {
			
		}
		
		public function loadThumbnailPhotoAtIndex(index:int, type:String = LOAD_PHOTO_TYPE_THUMBNAIL):void {
			
		}
		
		public function loadFullScreenPhotoAtIndex(index:int, type:String = LOAD_PHOTO_TYPE_FULL_SCREEN):void {
			
		}
		
		public function loadFullResolutionPhotoAtIndex(index:int, type:String = LOAD_PHOTO_TYPE_FULL_RESOLUTION):void {
			
		}
		
		public function getCurrentPhotoDimensions(type:String = "thumbnail"):PhotoDimensions {
			
			var dimensions:PhotoDimensions = new PhotoDimensions();
			dimensions.width = 150;
			dimensions.height = 150;
			
			return dimensions;
		}
		
		private function getPhotoDimensionsAtIndex(type:String = PHOTO_TYPE_THUMBNAIL):PhotoDimensions {
			
			var dimensions:PhotoDimensions = new PhotoDimensions();
			dimensions.width = 150;
			dimensions.height = 150;
			
			return dimensions;
		}
		
		private function drawPhotoToBitmapData(bitmapData:BitmapData, type:String):void {
			
		}
	}
}