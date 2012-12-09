package com.zutalor.gesture 
{
	import org.gestouch.gestures.Gesture;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ActiveGestureProperties
	{
		public var listener:Function;
		public var type:String;
		public var target:*; 
		public var gesture:Gesture;
		public var qualifiedClassName:String;
		public var eventTypes:Array;

		public function ActiveGestureProperties()
		{
			eventTypes = [];
		}
		
		public function dispose():void
		{	
			gesture.dispose();
			target = null;
			eventTypes = null;
		}
	}
}