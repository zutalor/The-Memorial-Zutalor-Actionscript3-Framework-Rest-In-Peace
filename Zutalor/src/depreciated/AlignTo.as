package Zutalor.src.depreciated
{
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */

	
	public class AlignTo
	{
		public static const STAGE:String = "stage";
		public static const KEEP:String = "keep";
		public static const LEFT:String = "left";
		public static const LEFT_THIRD:String = "leftThird";
		public static const RIGHT:String = "right";
		public static const RIGHT_THIRD:String = "rightThird";
		public static const CENTER:String = "center";
		public static const TOP:String = "top";
		public static const TOP_THIRD:String = "topThird";
		public static const BOTTOM:String = "bottom";
		public static const BOTTOM_THIRD:String = "bottomThird";
		
		private static var _horizontalPosition:String;
		private static var _verticalPosition:String;
		private static var _hPadding:Number;
		private static var _vPadding:Number;
		private static var _width:Number;
		private static var _height:Number;
		private static var _scale:Number;
		private static var _registrationIsAtCenter:Boolean;
		
		public static function sage(objectToAlign:DisplayObjectContainer, horizontalPosition:String, verticalPosition:String,
										hPadding:int=0, vPadding:int=0, scaleX:Number = 1, scaleY:Number = 1, registrationIsAtCenter:Boolean=false):void
		{
			_horizontalPosition = horizontalPosition;
			_verticalPosition = verticalPosition;
			_hPadding = hPadding * scaleX;
			_vPadding = vPadding * scaleY;
			
			_width = objectToAlign.width;
			_height = objectToAlign.height;
			
			_registrationIsAtCenter = registrationIsAtCenter;
			align(objectToAlign, objectToAlign.stage.stageWidth, objectToAlign.stage.stageHeight);
		}

		public static function diplayObject(objectToAlign:DisplayObject, objectToAlignTo:DisplayObject, horizontalPosition:String,
											verticalPosition:String, hPadding:int=0, vPadding:int=0, scale:Number = 1, registrationIsAtCenter:Boolean=false):void
		{
			_horizontalPosition = horizontalPosition;
			_verticalPosition = verticalPosition;
			_hPadding = hPadding * scale;
			_vPadding = vPadding * scale;
			
			_width = objectToAlign.width;
			_height = objectToAlign.height;
		
			_registrationIsAtCenter = registrationIsAtCenter;

			align(objectToAlign, objectToAlignTo.width, objectToAlignTo.height, objectToAlignTo.x, objectToAlignTo.y);
		}
		
		public static function size(objectToAlign:DisplayObject, width:int, height:int, horizontalPosition:String, verticalPosition:String,
				hPadding:int=0, vPadding:int=0):void
		{
			_horizontalPosition = horizontalPosition;
			_verticalPosition = verticalPosition;
			_hPadding = hPadding;
			_vPadding = vPadding;
			_width = objectToAlign.width;
			_height = objectToAlign.height;
			align(objectToAlign, width, height, 0, 0 );
		}
	
		private static function align(objectToAlign:DisplayObject, destWidth:Number, destHeight:Number, offSetX:Number = 0, offSetY:Number = 0):void
		{
			switch (_horizontalPosition)
			{
				case KEEP:
					break;
				case LEFT:
					objectToAlign.x = _hPadding;
					break;
				case RIGHT:
					objectToAlign.x = destWidth - _width - _hPadding;
					break;
				case CENTER:
					objectToAlign.x = (destWidth >> 1) - (_width >> 1) + _hPadding;
					break;
				case LEFT_THIRD:
					objectToAlign.x = (destWidth / 3) - (_width >> 1) + _hPadding;
					break;
				case RIGHT_THIRD:
					objectToAlign.x = (destWidth / 3) + (destWidth / 3) - (_width >> 1) + _hPadding;
					break;
			}
			switch (_verticalPosition)
			{
				case KEEP:
					break;
				case TOP:
					objectToAlign.y = _vPadding;
					break;
				case BOTTOM:
					objectToAlign.y = destHeight - _height - _vPadding;
					break;
				case CENTER:
					objectToAlign.y = (destHeight >> 1) - (_height >> 1) + _vPadding;
					break;
				case TOP_THIRD:
					objectToAlign.y = (destHeight / 3) - (_height >> 1) + _vPadding;
					break;
				case BOTTOM_THIRD:
					objectToAlign.y = destHeight - (destHeight / 3) - (_height >> 1) + _vPadding;
					break;
			}
			if (_registrationIsAtCenter)
			{
				objectToAlign.y += _height >> 1;
				objectToAlign.x += _width >> 1;
			}
			objectToAlign.x += offSetX;
			objectToAlign.y += offSetY;
		}
	}
}