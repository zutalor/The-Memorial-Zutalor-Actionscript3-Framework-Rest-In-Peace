package com.zutalor.air
{
	import com.gskinner.utils.FramerateThrottler;
	import com.zutalor.utils.StageRef;
	import flash.events.Event;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AirStatus
	{
		private static var _isNativeApplication:Boolean;
		private static var _isMobile:Boolean;
				
		public static function get isNativeApplication():Boolean
		{
			return _isNativeApplication;	
		}
		
		public static function get isMobile():Boolean
		{
			return _isMobile;
		}		
		
		public static function initialize():void
		{
			var c:*;
			
			c = Capabilities;//get away with compiling for flash 9
			if (c.playerType == "Desktop")
			{
				_isNativeApplication = true;
			}
			
			if (c.cpuArchitecture=="ARM" || c.screenDPI > 96)
			{
				_isNativeApplication = true;
				_isMobile = true;
			}			
		}		
	}
}