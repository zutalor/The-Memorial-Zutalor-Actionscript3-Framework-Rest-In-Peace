package com.zutalor.utils 
{
	import com.zutalor.gesture.GestureListener;
	import flash.display.Stage;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class StageRef
	{
		private static var _stage:Stage;
		private static var _gestureListener:GestureListener;
		
		public static function get stage():Stage
		{
			return _stage;
		}
		
		public static function set stage(s:Stage):void
		{
			_stage = s;
		}
		
		public static function addGestureListener(type:String, listener:Function):void
		{
			if (!_gestureListener)
				_gestureListener = new GestureListener(_stage);
	
			_gestureListener.activateGesture(type, listener);
		}
		
		public static function removeGestureListener(type:String):void
		{
			_gestureListener.deactivateGesture(type)
		}
		
/*		public static function removeAllGestureListeners():void TODO Buggy
		{
			_gestureListener.deactivateAllGestures();
		}
*/	
	}

}