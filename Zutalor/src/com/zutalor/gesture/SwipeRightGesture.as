package com.zutalor.gesture 
{
	import org.gestouch.gestures.SwipeGesture;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SwipeRightGesture extends SwipeGesture
	{
		
		public function SwipeRightGesture(target:Object = null) 
		{
			direction = GestureUtils.getSwipeDirection(GestureTypes.SWIPE_RIGHT);
		}
		
		override public function reflect():Class
		{
			return SwipeRightGesture;
		}
	}
}