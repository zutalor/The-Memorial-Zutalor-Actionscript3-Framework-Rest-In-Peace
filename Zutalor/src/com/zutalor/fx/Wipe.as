package com.zutalor.fx
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Wipe
	{
		private static var _parent:DisplayObjectContainer;
		private static var _destScaleX:Number;
		private static var _destScaleY:Number;
		private static var _destX:int;
		private static var _destY:int;
		private static var _scaleX:Number;
		private static var _scaleY:Number;
		
		public static function tweenParams(dc:DisplayObject, mask:Sprite, fxType:String, inOut:String):Object
		{					
			_parent = dc.parent;
			
			_scaleX = dc.scaleX; 	
			_scaleY = dc.scaleY; 
						
			mask.graphics.beginFill(0x000000);
			mask.graphics.drawRect(0, 0, dc.width + 5, dc.height + 5);
			mask.graphics.endFill();

			mask.x = _destX = dc.x;
			mask.y = _destY = dc.y;
			
			mask.scaleY = _destScaleY = _scaleY;
			mask.scaleX = _destScaleX = _scaleX;
			
			if (inOut == TransitionTypes.IN)
			{
				if (fxType.indexOf(TransitionTypes.WIPE_CENTER_VERT) != -1)
				{
					mask.y = dc.y + mask.height >> 1;
					mask.scaleY = 0;
					_destScaleY = _scaleY;
				}
				else if (fxType.indexOf(TransitionTypes.WIPE_CENTER_HORZ) != -1)
				{
					mask.x = dc.x + mask.width >> 1;
					mask.scaleX = 0;
					_destScaleX = _scaleX;
				}
				else if (fxType.indexOf(TransitionTypes.WIPE_LEFT) != -1)
					mask.x = dc.x - mask.width;
				else if (fxType.indexOf(TransitionTypes.WIPE_RIGHT) != -1)
					mask.x = dc.x + mask.width;
				else if (fxType.indexOf(TransitionTypes.WIPE_TOP) != -1)
					mask.y = dc.y - mask.height;
				else if (fxType.indexOf(TransitionTypes.WIPE_BOTTOM) != -1)
					mask.y = dc.y + mask.height;
				else
					mask.y = dc.y + mask.height;
			}
			else	
			{
				if (fxType.indexOf(TransitionTypes.WIPE_CENTER_VERT) != -1)
				{					
					_destY = dc.y + mask.height >> 1;
					_destScaleY = 0;
				}
				else if (fxType.indexOf(TransitionTypes.WIPE_CENTER_HORZ) != -1)
				{					
					_destX = dc.x + mask.width >> 1;
					_destScaleX = 0;
				}		
				else if (fxType.indexOf(TransitionTypes.WIPE_LEFT) != -1)
					_destX = dc.x + mask.width;
				else if (fxType.indexOf(TransitionTypes.WIPE_RIGHT) != -1)
					_destX = dc.x - mask.width;
				else if (fxType.indexOf(TransitionTypes.WIPE_TOP) != -1)
					_destY = dc.y + mask.height;
				else if (fxType.indexOf(TransitionTypes.WIPE_BOTTOM) != -1)
					_destY = dc.y - mask.height;
				else	
					_destY = dc.y - mask.height;
			}

			return { scaleX:_destScaleX, scaleY:_destScaleY, x:_destX, y:_destY };
		}	
	}
}