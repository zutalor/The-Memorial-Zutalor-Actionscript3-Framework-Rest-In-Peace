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
				
		
	}
}