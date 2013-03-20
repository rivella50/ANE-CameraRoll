package com.vlabs.ane.cameraroll
{
	public class PhotoObject
	{
		private var _metadata:PhotoMetadata;
		private var _photo:Object; // can be BitmapData or ByteArray
		
		public function PhotoObject()
		{
		}

		

		public function get metadata():PhotoMetadata
		{
			return _metadata;
		}

		public function set metadata(value:PhotoMetadata):void
		{
			_metadata = value;
		}

		public function get photo():Object
		{
			return _photo;
		}

		public function set photo(value:Object):void
		{
			_photo = value;
		}


	}
}