package com.zutalor.gesture 
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import org.gestouch.gestures.Gesture;
	/**
	 * ...
	 * @author Geoff
	 */
	public class GestureProperties
	{
		public var target:*; //Key
		public var gestureId:String; // key
		public var gesture:*;
		public var type:String; 
		public var callback:Function;
		public var eventTypes:Array;
		public var result:GestureResult;

		public function GestureProperties()
		{
			eventTypes = [];
			result = new GestureResult();
			result.location = new Point();
		}
	}
}