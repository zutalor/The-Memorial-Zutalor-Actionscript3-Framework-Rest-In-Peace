package com.zutalor.utils
{
	import com.zutalor.constants.Position;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */

	 
	public class SnapTo
	{
		private static var _horizontalPosition:String;
		private static var _verticalPosition:String;
		private static var _hPadding:int;
		private static var _vPadding:int;
		private static var _scale:Number;
		
		public static function displayObject(objectToSnap:DisplayObjectContainer, objectToSnapTo:DisplayObjectContainer, horizontalPosition:String, 
											verticalPosition:String, hPadding:int = 0, vPadding:int = 0, scale:Number = 1):void
		{
			_horizontalPosition = horizontalPosition;
			_verticalPosition = verticalPosition;
			_hPadding = hPadding;
			_vPadding = vPadding;
			_scale = scale;
		
			align(objectToSnap, objectToSnapTo);
		}
	
		private static function align(objectToSnap:DisplayObjectContainer, objectToSnapto:DisplayObjectContainer):void
		{
			
			switch (_horizontalPosition)
			{
				case Position.LEFT:
					objectToSnap.x = objectToSnapto.x - (_hPadding * _scale) ;
					break;
				case Position.RIGHT:
					objectToSnap.x = objectToSnapto.x + (objectToSnapto.width * _scale) + (_hPadding * _scale);
					break;
			}
			switch (_verticalPosition)
			{
				case Position.TOP:
					objectToSnap.y = objectToSnapto.y - (objectToSnap.height * _scale) - (_vPadding * _scale);
					break;
				case Position.BOTTOM:
					objectToSnap.y = objectToSnapto.y + (objectToSnapto.height * _scale) + (_vPadding * _scale);
					break;
			}
		}
	}
}