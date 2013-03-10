package com.vlabs.ane.cameraroll
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	
	public class CameraRollExtension extends EventDispatcher
	{
		private static var _instance:CameraRollExtension;
				
		private var _array:Array;
		
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
		
		
		
		public function countPhotos():void {
			
		}
		
		public function loadPhotoAssets():void {
			
		}
		
		public function getPhotoInfos(startIndex:int, length:int):Array {
			
			return [];
		}
		
		public function loadThumbnailPhotoForUrl(url:String):void {
			
		}
		
		public function loadFullScreenPhotoForUrl(url:String):void {
			
		}
		
		public function loadFullResolutionPhotoForUrl(url:String):void {
			
		}
		
		public function loadThumbnailPhotoAtIndex(index:int):void {
			
		}
		
		public function loadFullScreenPhotoAtIndex(index:int):void {
			
		}
		
		public function loadFullResolutionPhotoAtIndex(index:int):void {
			
		}
		
		public function getCurrentPhotoDimensions(type:String = "thumbnail"):PhotoDimensions {
			
			return null;
		}
		
		private function drawPhotoToBitmapData(bitmapData:BitmapData, type:String):void {
			
		}
	}
}