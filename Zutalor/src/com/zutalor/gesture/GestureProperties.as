package com.zutalor.gesture 
{
	import com.zutalor.interfaces.IAcceptsGestureCallbacks;
	import org.gestouch.gestures.Gesture;
	/**
	 * ...
	 * @author Geoff
	 */
	public class GestureProperties
	{
		public var type:String;
		public var target:*; 
		public var gesture:Gesture;
		public var eventTypes:Array;

		public function GestureProperties()
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