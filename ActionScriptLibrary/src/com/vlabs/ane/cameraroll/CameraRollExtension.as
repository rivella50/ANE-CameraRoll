package com.vlabs.ane.cameraroll
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	[Event(name=PhotoAppEvent.type, type="com.vlabs.ane.cameraroll.PhotoAppEvent")]
	public class CameraRollExtension extends EventDispatcher
	{
		private static const LOAD_PHOTO_TYPE_THUMBNAIL:String = "loadPhotoTypeThumbnail";
		private static const LOAD_PHOTO_TYPE_FULL_SCREEN:String = "loadPhotoTypeFullScreen";
		private static const LOAD_PHOTO_TYPE_FULL_RESOLUTION:String = "loadPhotoTypeFullResolution";
		
		private static const PHOTO_TYPE_THUMBNAIL:String = "thumbnail";
		private static const PHOTO_TYPE_FULL_SCREEN:String = "fullScreen";
		private static const PHOTO_TYPE_FULL_RESOLUTION:String = "fullResolution";
		
		private static var _instance:CameraRollExtension;
		
		private var _context:ExtensionContext;
		
		// since thumbnails all have the same dimensions we store it in context after first retrieval
		private var _thumbnailWidth:int;
		private var _thumbnailHeight:int;
		
		public function CameraRollExtension()
		{
			_context = ExtensionContext.createExtensionContext("com.vlabs.ane.cameraroll", null); 
			if (!_context) { 
				throw new Error( "CameraRoll native extension is not supported on this platform." ); 
			}
			
			_context.call("initNativeCode");
			_context.addEventListener(StatusEvent.STATUS, onStatusHandler);

		}
		
		protected function onStatusHandler(e:StatusEvent):void
		{
			if (e.code == "COUNT_PHOTOS_COMPLETED")	{
				
				var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_COUNT_PHOTOS);
				event.data = e.level;
				trace("received status event for count photos request ", e.level);
				dispatchEvent(event);
				
			} else if (e.code == "LOAD_PHOTO_THUMBNAILS_COMPLETED") {
				
				var bitmap:BitmapData;
				var byteArray:ByteArray;
				var amount:int = int(e.level);
				var object:PhotoObject;
				var infos:Array;
				if (amount > 0) {
					
					infos = getPhotoInfos(0, amount);
					
					var array:Array = [];
					for (var i:int = 0; i < amount; i++) {
						
						object = new PhotoObject();
						
						// https://github.com/freshplanet/ANE-ImagePicker/blob/master/actionscript/src/com/freshplanet/ane/AirImagePicker/AirImagePicker.as
						// 1st possibility: draw into a BitmapData
						bitmap = new BitmapData(150, 150);
						_context.call("drawThumbnailAtIndexToBitmapData", i, bitmap);
						object.thumbnail = bitmap;
						object.metadata = infos[i];
						array.push(object);
						
						// 2nd possibility: copy bytes into a ByteArray
						//byteArray = new ByteArray();
						//byteArray.length = _context.call("getJPEGRepresentationSizeAtIndex", i) as int;
						//_context.call("copyThumbnailJPEGRepresentationAtIndexToByteArray", i, byteArray);
						//array.push(byteArray);
						
					}
					
					var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_THUMBS_LOADED);
					event.data = array;
					dispatchEvent(event);
					return;
					
					
				} else {
					
					trace("there are no photos found in CameraRoll...");
				}
				
				
			} else if (e.code == LOAD_PHOTO_TYPE_THUMBNAIL) {
				
				var bitmap:BitmapData;
				var dimensions:PhotoDimensions = getCurrentPhotoDimensions(PHOTO_TYPE_THUMBNAIL);
				bitmap = new BitmapData(dimensions.width, dimensions.height);
				drawPhotoToBitmapData(bitmap, PHOTO_TYPE_THUMBNAIL);
				var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_FULLSCREEN_IMAGE_LOADED);
				event.data = bitmap;
				dispatchEvent(event);
				return;
			} else if (e.code == LOAD_PHOTO_TYPE_FULL_SCREEN) {
				
				var bitmap:BitmapData;
				var dimensions:PhotoDimensions = getCurrentPhotoDimensions(PHOTO_TYPE_FULL_SCREEN);
				bitmap = new BitmapData(dimensions.width, dimensions.height);
				drawPhotoToBitmapData(bitmap, PHOTO_TYPE_FULL_SCREEN);
				var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_FULLSCREEN_IMAGE_LOADED);
				event.data = bitmap;
				dispatchEvent(event);
				return;
			} else if (e.code == LOAD_PHOTO_TYPE_FULL_RESOLUTION) {
				
				var bitmap:BitmapData;
				var dimensions:PhotoDimensions = getCurrentPhotoDimensions(PHOTO_TYPE_FULL_RESOLUTION);
				bitmap = new BitmapData(dimensions.width, dimensions.height);
				drawPhotoToBitmapData(bitmap, PHOTO_TYPE_FULL_RESOLUTION);
				var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_FULLSCREEN_IMAGE_LOADED);
				event.data = bitmap;
				dispatchEvent(event);
				return;
			}

			
		}
		
		/**
		 * 
		 */
		private function assertThumbnailPhotoDimensions():void {
			
			
		}
		
		public static function getInstance() : CameraRollExtension
		{
			return _instance ? _instance : new CameraRollExtension();
		}
		
		public static function get isSupported():Boolean
		{
			return Capabilities.manufacturer.indexOf("iOS") > -1 || Capabilities.manufacturer.indexOf("Android") > -1;
		}
		
		//
		// API
		//
		
		public function initNativeCode():void {
			
			_context.call("initNativeCode", null);
		}
		
		
		public function countPhotos():void {
			
			_context.call("countPhotos", null);
		}
		
		public function loadPhotoAssets(startIndex:int, amount:int):void {
			
			_context.call("loadPhotoAssets", startIndex, amount);
		}
		
		public function getPhotoInfos(startIndex:int, length:int):Array {
			
			return _context.call("getPhotoInfos", startIndex, length) as Array;
		}
		
		public function loadThumbnailPhotoForUrl(url:String):void {
			
			_context.call("loadPhotoForUrl", url, LOAD_PHOTO_TYPE_THUMBNAIL);
		}
		
		public function loadFullScreenPhotoForUrl(url:String):void {
			
			_context.call("loadPhotoForUrl", url, LOAD_PHOTO_TYPE_FULL_SCREEN);
		}
		
		public function loadFullResolutionPhotoForUrl(url:String):void {
			
			_context.call("loadPhotoForUrl", url, LOAD_PHOTO_TYPE_FULL_RESOLUTION);
		}
		
		public function loadThumbnailPhotoAtIndex(index:int):void {
			
			_context.call("loadPhotoAtIndex", index, LOAD_PHOTO_TYPE_THUMBNAIL);
		}
		
		public function loadFullScreenPhotoAtIndex(index:int):void {
			
			_context.call("loadPhotoAtIndex", index, LOAD_PHOTO_TYPE_FULL_SCREEN);
		}
		
		public function loadFullResolutionPhotoAtIndex(index:int):void {
			
			_context.call("loadPhotoAtIndex", index, LOAD_PHOTO_TYPE_FULL_RESOLUTION);
		}
		
		public function getCurrentPhotoDimensions(type:String = PHOTO_TYPE_THUMBNAIL):PhotoDimensions {
			
			return _context.call("getCurrentPhotoDimensions", type) as PhotoDimensions;
		}
		
		private function drawPhotoToBitmapData(bitmapData:BitmapData, type:String):void {
			
			_context.call("drawPhotoToBitmapData", bitmapData, type);
		}
	}
}