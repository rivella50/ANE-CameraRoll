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
		
		public function sayHello(name:String):String {
			
			return "";
		}
		
		public function countPhotos():void {
			
		}
		
		public function loadPhotoThumbnails3():void {
			
		}
		
		public function getPhotoInfos(startIndex:int, length:int):Array {
			
			return [];
		}
		
		public function loadPhotoFullScreen(url:String):void {
			
		}
		
		public function getCurrentFullScreenPhotoDimensions():PhotoDimensions {
			
			return null;
		}
		
		public function drawFullScreenPhotoToBitmapData(bitmapData:BitmapData):void {
			
			
		}
	}
}