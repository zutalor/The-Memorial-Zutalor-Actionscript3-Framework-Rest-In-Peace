package com.zutalor.transition 
{
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Move
	{
		private static var _destX:int;
		private static var _destY:int;
		private static var _xValue:Number;
		private static var _yValue:Number;
		
		public static function tweenParams(dc:DisplayObject, fxType:String, inOut:String, xValue:Number, yValue:Number):Object
		{
							
			_destX = dc.x;
			_destY = dc.y;
			
			if (inOut == TransitionTypes.IN)
			{
				_xValue = xValue;
				_yValue = yValue;
			}
			else
			{
				_xValue = xValue * -1;
				_yValue = yValue * -1;
			}
			
			if (fxType.indexOf(TransitionTypes.MOVE_X) != -1) 
			{
				_destX = dc.x + xValue;	
			}
			
			if (fxType.indexOf(TransitionTypes.MOVE_Y) != -1)
			{
				_destY = dc.y + yValue;
			}
			
			if (fxType.indexOf(TransitionTypes.MOVE_X_TO) != -1) 
			{
				_destX = xValue;	
			}
			
			if (fxType.indexOf(TransitionTypes.MOVE_Y_TO) != -1)
			{
				_destY = yValue;
			}			
			return { x:_destX, y:_destY };
		}		
	}

}