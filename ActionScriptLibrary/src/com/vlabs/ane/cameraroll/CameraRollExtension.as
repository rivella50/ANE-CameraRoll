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
		private static const LOAD_PHOTO_TYPE_THUMBNAILS:String = "loadPhotoTypeThumbnails";
		private static const LOAD_PHOTO_TYPE_THUMBNAILS_FOR_URLS:String = "loadPhotoTypeThumbnailsForUrls";
		
		private static const LOAD_PHOTO_TYPE_THUMBNAIL:String = "loadPhotoTypeThumbnail";
		private static const LOAD_PHOTO_TYPE_FULL_SCREEN:String = "loadPhotoTypeFullScreen";
		private static const LOAD_PHOTO_TYPE_FULL_RESOLUTION:String = "loadPhotoTypeFullResolution";
		
		private static const LOAD_PHOTO_TYPE_THUMBNAIL_FOR_DIMENSIONS:String = "loadPhotoTypeThumbnailForDimensions";
		
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
			trace("status code is: ", e.code);
			if (e.code == "COUNT_PHOTOS_COMPLETED")	{
				
				var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_COUNT_PHOTOS);
				event.data = e.level;
				trace("received status event for count photos request ", e.level);
				dispatchEvent(event);
				
			} else if (e.code === LOAD_PHOTO_TYPE_THUMBNAILS) {
				
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
						bitmap = new BitmapData(_thumbnailWidth, _thumbnailHeight);
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
				
				
			} else if (e.code === LOAD_PHOTO_TYPE_THUMBNAILS_FOR_URLS) {
			
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
						bitmap = new BitmapData(_thumbnailWidth, _thumbnailHeight);
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
					
					var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_THUMBS_FOR_URLS_LOADED);
					event.data = array;
					dispatchEvent(event);
					return;
					
					
				} else {
					
					trace("there are no photos for urls found in CameraRoll...");
				}
				
			} else if (e.code == LOAD_PHOTO_TYPE_THUMBNAIL) {
				
				var bitmap:BitmapData;
				var dimensions:PhotoDimensions = getCurrentPhotoDimensions(PHOTO_TYPE_THUMBNAIL);
				bitmap = new BitmapData(dimensions.width, dimensions.height);
				drawPhotoToBitmapData(bitmap, PHOTO_TYPE_THUMBNAIL);
				var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_THUMBNAIL_IMAGE_LOADED);
				event.data = bitmap;
				dispatchEvent(event);
				return;
			} else if (e.code == LOAD_PHOTO_TYPE_FULL_SCREEN) {
				
				var bitmap:BitmapData;
				var dimensions:PhotoDimensions = getCurrentPhotoDimensions(PHOTO_TYPE_FULL_SCREEN);
				bitmap = new BitmapData(dimensions.width, dimensions.height);
				drawPhotoToBitmapData(bitmap, PHOTO_TYPE_FULL_SCREEN);
				var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_FULL_SCREEN_IMAGE_LOADED);
				event.data = bitmap;
				dispatchEvent(event);
				return;
			} else if (e.code == LOAD_PHOTO_TYPE_FULL_RESOLUTION) {
				
				var bitmap:BitmapData;
				var dimensions:PhotoDimensions = getCurrentPhotoDimensions(PHOTO_TYPE_FULL_RESOLUTION);
				bitmap = new BitmapData(dimensions.width, dimensions.height);
				drawPhotoToBitmapData(bitmap, PHOTO_TYPE_FULL_RESOLUTION);
				var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_FULL_RESOLUTION_IMAGE_LOADED);
				event.data = bitmap;
				dispatchEvent(event);
				return;
			} else if (e.code == LOAD_PHOTO_TYPE_THUMBNAIL_FOR_DIMENSIONS) {
				
				var dimensions:PhotoDimensions = getCurrentPhotoDimensions(PHOTO_TYPE_THUMBNAIL);
				var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_DEFAULT_THUMBNAIL_DIMENSIONS_LOADED);
				event.data = dimensions;
				dispatchEvent(event);
				return;
			}

			
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
		
		/**
		 * This is a 2-step call to context: First load the first thumbnail in CameraRoll and after returning get the
		 * dimensions.
		 */
		public function determineThumbnailDefaultDimensions():void {
			
			loadThumbnailPhotoAtIndex(0, LOAD_PHOTO_TYPE_THUMBNAIL_FOR_DIMENSIONS);
		}
		
		
		public function countPhotos():void {
			
			_context.call("countPhotos", null);
		}
		
		public function loadThumbnailPhotoAssets(startIndex:int, amount:int, thumbnailWidth:int, thumbnailHeight:int, type:String = LOAD_PHOTO_TYPE_THUMBNAILS):void {
			
			_thumbnailWidth = thumbnailWidth;
			_thumbnailHeight = thumbnailHeight;
			_context.call("loadPhotoAssets", startIndex, amount, type);
		}
		
		public function loadThumbnailPhotoAssetsForUrls(urls:Array, thumbnailWidth:int, thumbnailHeight:int, type:String = LOAD_PHOTO_TYPE_THUMBNAILS_FOR_URLS):void {
			
			_thumbnailWidth = thumbnailWidth;
			_thumbnailHeight = thumbnailHeight;
			_context.call("loadPhotoAssetsForUrls", urls, type);
		}
		
		public function getPhotoInfos(startIndex:int, length:int):Array {
			
			return _context.call("getPhotoInfos", startIndex, length) as Array;
		}
		
		public function loadThumbnailPhotoForUrl(url:String, type:String = LOAD_PHOTO_TYPE_THUMBNAIL):void {
			
			_context.call("loadPhotoForUrl", url, type);
		}
		
		public function loadFullScreenPhotoForUrl(url:String, type:String = LOAD_PHOTO_TYPE_FULL_SCREEN):void {
			
			_context.call("loadPhotoForUrl", url, type);
		}
		
		public function loadFullResolutionPhotoForUrl(url:String, type:String = LOAD_PHOTO_TYPE_FULL_RESOLUTION):void {
			
			_context.call("loadPhotoForUrl", url, type);
		}
		
		public function loadThumbnailPhotoAtIndex(index:int, type:String = LOAD_PHOTO_TYPE_THUMBNAIL):void {
			
			_context.call("loadPhotoAtIndex", index, type);
		}
		
		public function loadFullScreenPhotoAtIndex(index:int, type:String = LOAD_PHOTO_TYPE_FULL_SCREEN):void {
			
			_context.call("loadPhotoAtIndex", index, type);
		}
		
		public function loadFullResolutionPhotoAtIndex(index:int, type:String = LOAD_PHOTO_TYPE_FULL_RESOLUTION):void {
			
			_context.call("loadPhotoAtIndex", index, type);
		}
		
		public function getCurrentPhotoDimensions(type:String = PHOTO_TYPE_THUMBNAIL):PhotoDimensions {
			
			return _context.call("getCurrentPhotoDimensions", type) as PhotoDimensions;
		}
		
		private function drawPhotoToBitmapData(bitmapData:BitmapData, type:String):void {
			
			_context.call("drawPhotoToBitmapData", bitmapData, type);
		}
	}
}