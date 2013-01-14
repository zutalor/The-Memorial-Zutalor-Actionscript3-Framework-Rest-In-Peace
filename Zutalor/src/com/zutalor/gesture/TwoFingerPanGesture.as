package com.zutalor.gesture 
{
	import org.gestouch.gestures.PanGesture;
	/**
	 * ...
	 * @author Geoff
	 */
	public class TwoFingerPanGesture extends PanGesture
	{
		public function DoubleTapGesture(target:Object = null) 
		{
			super(target);
			minNumTouchesRequired = 2;
			maxNumTouchesRequired = 2;
		}
		
		override public function reflect():Class
		{
			return TwoFingerPanGesture;
		}
	}
}