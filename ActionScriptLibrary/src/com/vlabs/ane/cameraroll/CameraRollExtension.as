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
		public static const LOAD_PHOTO_TYPE_THUMBNAILS:String = "loadPhotoTypeThumbnails";
		public static const LOAD_PHOTO_TYPE_ASPECT_RATIO_THUMBNAILS:String = "loadPhotoTypeAspectRatioThumbnails";
		public static const LOAD_PHOTO_TYPE_THUMBNAILS_FOR_URLS:String = "loadPhotoTypeThumbnailsForUrls";
		public static const LOAD_PHOTO_TYPE_ASPECT_RATIO_THUMBNAILS_FOR_URLS:String = "loadPhotoTypeAspectRatioThumbnailsForUrls";
		
		public static const LOAD_PHOTO_TYPE_THUMBNAIL:String = "loadPhotoTypeThumbnail";
		public static const LOAD_PHOTO_TYPE_ASPECT_RATIO_THUMBNAIL:String = "loadPhotoTypeAspectRatioThumbnail";
		public static const LOAD_PHOTO_TYPE_FULL_SCREEN:String = "loadPhotoTypeFullScreen";
		public static const LOAD_PHOTO_TYPE_FULL_RESOLUTION:String = "loadPhotoTypeFullResolution";
		
		private static const LOAD_PHOTO_TYPE_THUMBNAIL_FOR_DIMENSIONS:String = "loadPhotoTypeThumbnailForDimensions";
		
		private static const PHOTO_TYPE_THUMBNAIL:String = "thumbnail";
		private static const PHOTO_TYPE_ASPECT_RATIO_THUMBNAIL:String = "aspectRatioThumbnail";
		private static const PHOTO_TYPE_FULL_SCREEN:String = "fullScreen";
		private static const PHOTO_TYPE_FULL_RESOLUTION:String = "fullResolution";
		
		private static const COUNT_PHOTOS_COMPLETED:String = "countPhotosCompleted";
		
		private static const REQUEST_SUCCESSFUL:String = "OK";
		private static const REQUEST_FAILED:String = "NOK";
		
		private static var _instance:CameraRollExtension;
		
		private var _context:ExtensionContext;
		
		
		private var _photoType:String;
		
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
			//trace("status code is: ", e.code);
			if (e.code == COUNT_PHOTOS_COMPLETED)	{
				
				var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_COUNT_PHOTOS);
				event.data = e.level;
				//trace("received status event for count photos request ", e.level);
				dispatchEvent(event);
				
			} else if (e.code == LOAD_PHOTO_TYPE_THUMBNAILS || e.code == LOAD_PHOTO_TYPE_ASPECT_RATIO_THUMBNAILS) {
				
				var bitmap:BitmapData;
				var byteArray:ByteArray;
				var amount:int = int(e.level);
				var object:PhotoObject;
				var infos:Array;
				var dimensions:PhotoDimensions;
				var array:Array = [];
				
				if (amount > 0) {
					
					infos = getPhotoInfos(0, amount);
					
					for (var i:int = 0; i < amount; i++) {
						
						object = new PhotoObject();
						
						// https://github.com/freshplanet/ANE-ImagePicker/blob/master/actionscript/src/com/freshplanet/ane/AirImagePicker/AirImagePicker.as
						// 1st possibility: draw into a BitmapData
						dimensions = getPhotoDimensionsAtIndex(i, _photoType);
						bitmap = new BitmapData(dimensions.width, dimensions.height);
						//trace("bitmap: ", bitmap.width,"/", bitmap.height);
						_context.call("drawThumbnailAtIndexToBitmapData", i, bitmap, _photoType);
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
					
					//trace("there are no photos found in CameraRoll...");
					var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_THUMBS_LOADED);
					event.data = array;
					dispatchEvent(event);
					return;
				}
				
				
			} else if (e.code == LOAD_PHOTO_TYPE_THUMBNAILS_FOR_URLS || e.code == LOAD_PHOTO_TYPE_ASPECT_RATIO_THUMBNAILS_FOR_URLS) {
			
				var bitmap:BitmapData;
				var byteArray:ByteArray;
				var amount:int = int(e.level);
				var object:PhotoObject;
				var infos:Array;
				var dimensions:PhotoDimensions;
				var array:Array = [];
				
				if (amount > 0) {
					
					infos = getPhotoInfos(0, amount);
					
					for (var i:int = 0; i < amount; i++) {
						
						object = new PhotoObject();
						
						// https://github.com/freshplanet/ANE-ImagePicker/blob/master/actionscript/src/com/freshplanet/ane/AirImagePicker/AirImagePicker.as
						// 1st possibility: draw into a BitmapData
						dimensions = getPhotoDimensionsAtIndex(i, _photoType);
						bitmap = new BitmapData(dimensions.width, dimensions.height);
						_context.call("drawThumbnailAtIndexToBitmapData", i, bitmap, _photoType);
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
					
					//trace("there are no photos for urls found in CameraRoll...");
					var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_THUMBS_FOR_URLS_LOADED);
					event.data = array;
					dispatchEvent(event);
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
				
				// check if the photo could be loaded first
				if (e.level == REQUEST_SUCCESSFUL) {
				
					var dimensions:PhotoDimensions = getCurrentPhotoDimensions(PHOTO_TYPE_THUMBNAIL);
					var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_DEFAULT_THUMBNAIL_DIMENSIONS_LOADED);
					event.data = dimensions;
					dispatchEvent(event);
				} else {
					
					var event:PhotoAppEvent = new PhotoAppEvent(PhotoAppEvent.EVENT_DEFAULT_THUMBNAIL_DIMENSIONS_NOT_LOADED);
					dispatchEvent(event);
				}
				
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
		
		/**
		 * Async counts the numer of photos in CameraRoll. Dispatches an event of type 
		 */
		public function countPhotos():void {
			
			_context.call("countPhotos", null);
		}
		
		/**
		 * Async loads a number of photo assets with offset startIndex of either type thumbnail or aspectRatioThumbnail
		 */
		public function loadThumbnailPhotoAssets(startIndex:int, amount:int, type:String = LOAD_PHOTO_TYPE_THUMBNAILS):void {
			
			if (type == LOAD_PHOTO_TYPE_THUMBNAILS)
				_photoType = PHOTO_TYPE_THUMBNAIL;
			else if (type == LOAD_PHOTO_TYPE_ASPECT_RATIO_THUMBNAILS)
				_photoType = PHOTO_TYPE_ASPECT_RATIO_THUMBNAIL;
			
			_context.call("loadPhotoAssets", startIndex, amount, type);
		}
		
		/**
		 * Async loads a number of photo assets for the passed list of url's of either type thumbnail or aspectRatioThumbnail
		 */
		public function loadThumbnailPhotoAssetsForUrls(urls:Array, type:String = LOAD_PHOTO_TYPE_THUMBNAILS_FOR_URLS):void {
			
			if (type == LOAD_PHOTO_TYPE_THUMBNAILS_FOR_URLS)
				_photoType = PHOTO_TYPE_THUMBNAIL;
			else if (type == LOAD_PHOTO_TYPE_ASPECT_RATIO_THUMBNAILS_FOR_URLS)
				_photoType = PHOTO_TYPE_ASPECT_RATIO_THUMBNAIL;
			
			_context.call("loadPhotoAssetsForUrls", urls, type);
		}
		
		/**
		 * Sync loads metadata for loaded photo assets.
		 * Be careful: This call doesn't load photo assets, therefore you have to load the before that call!
		 */
		public function getPhotoInfos(startIndex:int, length:int):Array {
			
			return _context.call("getPhotoInfos", startIndex, length) as Array;
		}
		
		/**
		 * Async loads one photo asset for the given url and the type thumbnail.
		 */
		public function loadThumbnailPhotoForUrl(url:String, type:String = LOAD_PHOTO_TYPE_THUMBNAIL):void {
			
			_context.call("loadPhotoForUrl", url, type);
		}
		
		/**
		 * Async loads one photo asset for the given url and the type fullscreen.
		 */
		public function loadFullScreenPhotoForUrl(url:String, type:String = LOAD_PHOTO_TYPE_FULL_SCREEN):void {
			
			_context.call("loadPhotoForUrl", url, type);
		}
		
		/**
		 * Async loads one photo asset for the given url and the type fullresolution.
		 */
		public function loadFullResolutionPhotoForUrl(url:String, type:String = LOAD_PHOTO_TYPE_FULL_RESOLUTION):void {
			
			_context.call("loadPhotoForUrl", url, type);
		}
		
		/**
		 * Async loads one photo asset from CameraRoll for the given url and the type thumbnail.
		 */
		public function loadThumbnailPhotoAtIndex(index:int, type:String = LOAD_PHOTO_TYPE_THUMBNAIL):void {
			
			_context.call("loadPhotoAtIndex", index, type);
		}
		
		/**
		 * Async loads one photo asset from CameraRoll for the given url and the type fullscreen.
		 */
		public function loadFullScreenPhotoAtIndex(index:int, type:String = LOAD_PHOTO_TYPE_FULL_SCREEN):void {
			
			_context.call("loadPhotoAtIndex", index, type);
		}
		
		/**
		 * Async loads one photo asset from CameraRoll for the given url and the type fullresolution.
		 */
		public function loadFullResolutionPhotoAtIndex(index:int, type:String = LOAD_PHOTO_TYPE_FULL_RESOLUTION):void {
			
			_context.call("loadPhotoAtIndex", index, type);
		}
		
		/**
		 * Sync gets the dimensions for the currently loaded single photo asset of type thumbnail
		 */
		public function getCurrentPhotoDimensions(type:String = PHOTO_TYPE_THUMBNAIL):PhotoDimensions {
			
			return _context.call("getCurrentPhotoDimensions", type) as PhotoDimensions;
		}
		
		/**
		 * Sync gets the dimensions for the photo asset loaded previously at the given index
		 */
		private function getPhotoDimensionsAtIndex(index:int, type:String = PHOTO_TYPE_THUMBNAIL):PhotoDimensions {
			
			return _context.call("getPhotoDimensionsAtIndex", index, type) as PhotoDimensions;
		}
		
		/**
		 * Sync draws the current loaded asset into the passed BitmapData for the given type
		 */
		private function drawPhotoToBitmapData(bitmapData:BitmapData, type:String):void {
			
			_context.call("drawPhotoToBitmapData", bitmapData, type);
		}
	}
}