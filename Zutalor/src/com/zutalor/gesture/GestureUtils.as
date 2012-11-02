package com.zutalor.gesture 
{
	import com.zutalor.utils.StageRef;
	import flash.geom.Point;
	import org.gestouch.gestures.PanGestureDirection;
	import org.gestouch.gestures.SwipeGestureDirection;
	/**
	 * ...
	 * @author Geoff
	 */
	public class GestureUtils 
	{
		public static function getSwipeDirection(dir:String):uint
		{
			var direction:uint;
			
			switch (dir)
			{
				case GestureTypes.SWIPE_LEFT :
					direction | SwipeGestureDirection.LEFT;
					break;
				case GestureTypes.SWIPE_RIGHT :
					direction | SwipeGestureDirection.RIGHT;
					break;
				case GestureTypes.SWIPE_UP :
					direction | SwipeGestureDirection.UP;
					break;
				case GestureTypes.SWIPE_DOWN :
					direction | SwipeGestureDirection.DOWN;
					break;
				case GestureTypes.SWIPE_VERTICAL :
					direction | SwipeGestureDirection.VERTICAL;
					break;
				case GestureTypes.SWIPE_HORIZONTAL :
					direction | SwipeGestureDirection.HORIZONTAL;
					break;
				case GestureTypes.SWIPE_ORTHOGONAL :
					direction | SwipeGestureDirection.ORTHOGONAL;
					break;
				case GestureTypes.SWIPE_NO_DIRECTION :
				default :
					direction | SwipeGestureDirection.NO_DIRECTION;
			}
			return direction;
		}
		
	
		
		public static function getPanDirection(type:String):uint
		{
			switch (type)
			{
				case GestureTypes.PAN_HORIZONTAL :
					return PanGestureDirection.HORIZONTAL;
					break;
				case GestureTypes.PAN_VERTICAL :
					return PanGestureDirection.VERTICAL;
					break;
				default :
					return PanGestureDirection.NO_DIRECTION;
					break;
			}
		}
				
		public static function translateTapRequest(location:Point, tapAreasHorz:int, tapAreasVert:int):String
		{
			var splitVert:Number;
			var splitHorz:Number;
			var h:int;
			var v:int;
			var i:int;
			
			splitHorz = StageRef.stage.stageWidth / tapAreasHorz;
			splitVert = StageRef.stage.stageHeight / tapAreasVert;

			for (i = 1; i <= tapAreasHorz; i++)			
				if (location.x < splitHorz * i)
				{
					h = i;
					break;
				}
				
				
			for (i = 1; I <= tapAreasVert; i++)
				if (location.y < splitHorz * i)
				{
					v = i
					break;
				}
		}	
	}
}