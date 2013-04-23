package com.vlabs.ane.cameraroll.example
{
	import com.vlabs.ane.cameraroll.CameraRollExtension;
	import com.vlabs.ane.cameraroll.PhotoAppEvent;
	import com.vlabs.ane.cameraroll.PhotoDimensions;
	import com.vlabs.ane.cameraroll.PhotoMetadata;
	import com.vlabs.ane.cameraroll.PhotoObject;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import flash.media.MediaPromise;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	/**
	 *  Tests how well the communication with the ANE is when using standard as3 and CPU
	 * 
	 */
	
	[SWF(width="640", height="920", frameRate="20", backgroundColor="#000000")]	// iPhone 4
	public class LoadImagesExample extends Sprite
	{
		private var _loader:Loader;
		private var _promise:MediaPromise;
		private var _roll:CameraRollExtension;
		private var _thumbsSprite:Sprite;
		private var _fullScreenSprite:Sprite;
		private var _i:int;
		private var _pageCounter:int = 0;
		private var _thumbsPerPage:int = 20;
		
		private var _currentAssetUrls:Array = [];
		
		public function LoadImagesExample()
		{
			super();
			_roll = new CameraRollExtension();
			// first do the thumbnail size determination
			trace("first the thumbnail default size...");
			_roll.addEventListener(PhotoAppEvent.EVENT_DEFAULT_THUMBNAIL_DIMENSIONS_LOADED, function(e:PhotoAppEvent):void {
				
				var data:PhotoDimensions = e.data as PhotoDimensions;
				trace("thumbnail dimensions are " + data.width + "x" + data.height);
				init();
			});
			_roll.determineThumbnailDefaultDimensions();
		}
		
		private function init():void {
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			var image:Sprite;
			
			// this is loading the thumbs by index
			var mySprite:Sprite = new Sprite(); 			
			mySprite.graphics.beginFill(0x336699); 
			mySprite.graphics.drawRect(0,0,100,100); 
			addChild(mySprite);
			mySprite.addEventListener(TouchEvent.TOUCH_TAP, function(e:TouchEvent):void {
				
				_fullScreenSprite.visible = false;
				_thumbsSprite.removeChildren();
				_roll.loadThumbnailPhotoAssets(_pageCounter * _thumbsPerPage, _thumbsPerPage, CameraRollExtension.LOAD_PHOTO_TYPE_THUMBNAILS);
				_pageCounter += 1;
			});
			mySprite.x = mySprite.y = 0;
			
			// this is loading the thumbs by urls
			var mySprite1:Sprite = new Sprite(); 			
			mySprite1.graphics.beginFill(0x666666); 
			mySprite1.graphics.drawRect(0,0,100,100); 
			addChild(mySprite1);
			mySprite1.addEventListener(TouchEvent.TOUCH_TAP, function(e:TouchEvent):void {
				
				_fullScreenSprite.visible = false;
				_thumbsSprite.removeChildren();
				trace("trying to load photos for ", _currentAssetUrls.length, " urls... ", _currentAssetUrls[0]);
				_roll.loadThumbnailPhotoAssetsForUrls(_currentAssetUrls, CameraRollExtension.LOAD_PHOTO_TYPE_THUMBNAILS);
			});
			mySprite1.x = mySprite.width*2;
			mySprite1.y = 0;
			
			_thumbsSprite = new Sprite();
			addChild(_thumbsSprite);
			_thumbsSprite.y = mySprite.height;
			_thumbsSprite.addEventListener(TouchEvent.TOUCH_TAP, function(e:TouchEvent):void {
				
				var target:Object = e.target;
				if (target is BitmapObject) {
					var metadata:PhotoMetadata = (target as BitmapObject).metadata;
					_roll.loadFullScreenPhotoForUrl(metadata.url);
				}
				
			});
			
			// this is when thumbs from indices get back from loading
			_roll.addEventListener(PhotoAppEvent.EVENT_THUMBS_LOADED, function(e:PhotoAppEvent):void {
				
				var list:Array = e.data as Array;
				var rowCounter:int = 0;
				var columnCounter:int = 0;
				var object:PhotoObject;
				_currentAssetUrls = [];
				
				for (var i:int = 0; i < list.length; i++) {
					
					object = list[i] as PhotoObject;
					
					image = new BitmapObject(new Bitmap(object.photo as BitmapData), object.metadata);
					_thumbsSprite.addChild(image);
					image.x = columnCounter*image.width;
					image.y = rowCounter*image.height;
					
					columnCounter++;
					if ((columnCounter+1) * image.width >= stage.stageWidth) {
						
						rowCounter++;
						columnCounter = 0;
					}
					
					// and fill in the url from that photo
					if (i % 2 == 0)
						_currentAssetUrls.push(object.metadata.url);
				}
				
				trace("done rendering ", list.length, " photos");
			});
			
			// this is when thumbs from urls get back from loading
			_roll.addEventListener(PhotoAppEvent.EVENT_THUMBS_FOR_URLS_LOADED, function(e:PhotoAppEvent):void {
				
				var list:Array = e.data as Array;
				var rowCounter:int = 0;
				var columnCounter:int = 0;
				var object:PhotoObject;
				
				for (var i:int = 0; i < list.length; i++) {
					
					object = list[i] as PhotoObject;
					
					image = new BitmapObject(new Bitmap(object.photo as BitmapData), object.metadata);
					_thumbsSprite.addChild(image);
					image.x = columnCounter*image.width;
					image.y = rowCounter*image.height;
					
					columnCounter++;
					if ((columnCounter+1) * image.width >= stage.stageWidth) {
						
						rowCounter++;
						columnCounter = 0;
					}
					
					
				}
				
				trace("done rendering ", list.length, " photos");
			});
			
			_fullScreenSprite = new Sprite();
			addChild(_fullScreenSprite);
			_fullScreenSprite.y = mySprite.height;
			_fullScreenSprite.visible = false;
			
			_roll.addEventListener(PhotoAppEvent.EVENT_FULL_SCREEN_IMAGE_LOADED, function(e:PhotoAppEvent):void {
				
				_fullScreenSprite.removeChildren();
				image = new BitmapObject(new Bitmap(e.data.photo as BitmapData), null);
				image.addEventListener(TouchEvent.TOUCH_TAP, function(e:TouchEvent):void {
					
					_fullScreenSprite.visible = false;
				});
				_fullScreenSprite.addChild(image);
				_fullScreenSprite.visible = true;
			});
		}
	}
}