package com.zutalor.gesture 
{
	import com.zutalor.interfaces.IAcceptsGestureCallbacks;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.Gesture;
	/**
	 * ...
	 * @author Geoff
	 */
	public class GestureProperties
	{
		public var target:*; //Key
		public var name:String;
		public var gestureQualifiedClassName:String; // key
		public var gesture:*;
		public var type:String; 
		public var caller:IAcceptsGestureCallbacks;
		public var eventTypes:Array;
		public var result:GestureResult;
		public var gestureEvent:GestureEvent;

		public function GestureProperties()
		{
			eventTypes = [];
			result = new GestureResult();
			result.location = new Point();
		}
		
		public function dispose():void
		{
			
			if (type != GestureTypes.KEY_PRESS)
				gesture.dispose();

			target = null;
			gesture = null;
			caller = null;
			eventTypes = null;
			result.location = null;
			result = null;
		}
	}
}