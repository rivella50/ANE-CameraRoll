package com.vlabs.ane.cameraroll.example
{
	import com.vlabs.ane.cameraroll.PhotoMetadata;
	
	import flash.display.Sprite;
	
	public class BitmapObject extends Sprite
	{
		private var _metadata:PhotoMetadata;
		
		public function BitmapObject(bitmap:*, metadata:PhotoMetadata)
		{
			super();
			addChild(bitmap);
			_metadata = metadata;	
		}
		
		
		public function get metadata():PhotoMetadata
		{
			return _metadata;
		}
		
		public function set metadata(value:PhotoMetadata):void
		{
			_metadata = value;
		}
		
	}
}