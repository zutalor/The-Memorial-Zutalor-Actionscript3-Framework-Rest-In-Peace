package com.zutalor.gesture 
{
	import org.gestouch.gestures.TapGesture;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DoubleTapGesture extends TapGesture
	{
		public function DoubleTapGesture(target:Object = null) 
		{
			super(target);
			numTapsRequired = 2;
		}
		
		override public function reflect():Class
		{
			return DoubleTapGesture;
		}
	}
}