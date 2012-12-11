package com.zutalor.gesture 
{
	import org.gestouch.gestures.Gesture;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ActiveGestureProperties
	{
		public var type:String;
		public var listener:Function;
		public var gesture:Gesture;
		public var eventTypes:Array;

		public function ActiveGestureProperties()
		{
			eventTypes = [];
		}
		
		public function dispose():void
		{	
			gesture.dispose();
			listener = null;
			eventTypes = null;
		}
	}
}