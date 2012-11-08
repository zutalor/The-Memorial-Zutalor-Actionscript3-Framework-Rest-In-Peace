package com.zutalor.gesture
{
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AppGestureProperties extends PropertiesBase
	{
		private var _actions:Array;
		
		public var gestureType:String;
		public var action:String;
		public var rows:int;
		public var cols:int;
		public var sound:String;
		
		public function AppGestureProperties()
		{
			if (actions && action.indexOf(",") != -1)
				_actions = action.split(",");
		}
		
		public function get actions():Array
		{
			if (_actions)
				return _actions;
			else
				return null;
		}
	}
}