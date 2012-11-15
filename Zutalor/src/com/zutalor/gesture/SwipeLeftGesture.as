package com.zutalor.gesture 
{
	import org.gestouch.gestures.SwipeGesture;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SwipeLeftGesture extends SwipeGesture
	{
		
		public function SwipeLeftGesture(target:Object = null) 
		{
			direction = GestureUtils.getSwipeDirection(GestureTypes.SWIPE_LEFT);
		}
		
		override public function reflect():Class
		{
			return SwipeLeftGesture;
		}
	}
}