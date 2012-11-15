package com.zutalor.application 
{
	import com.zutalor.utils.Registry;
	import org.gestouch.gestures.Gesture;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AppRegistry
	{
		public static var gestures:Registry;
		public var components:Registry;
		
		public static function initialize():void
		{
			gestures = new Registry(Gesture);
		}
	}
}