package com.vlabs.ane.cameraroll
{
	public class PhotoObject
	{
		private var _metadata:PhotoMetadata;
		private var _thumbnail:Object; // can be BitmapData or ByteArray
		
		public function PhotoObject()
		{
		}

		public function get thumbnail():Object
		{
			return _thumbnail;
		}

		public function set thumbnail(value:Object):void
		{
			_thumbnail = value;
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