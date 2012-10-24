package com.zutalor.utils
{
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MasterClock
	{
		private static var _tr:TimerRegistery;
						
		public static function initialize():void
		{
			_tr = new TimerRegistery();
		}
		
		public static function set defaultInterval(ms:int):void
		{
			_tr.defaultInterval = ms;
		}
		
		public static function get defaultInterval():int
		{
			return _tr.defaultInterval;
		}
				
		public static function isRegistered(callback:Function):Boolean
		{
			return _tr.isRegistered(callback);
		}
		
		public static function modifyInterval(callback:Function, ms:int):void
		{
			_tr.modifyInterval(callback, ms);
		}
		
		public static function registerCallback(callback:Function, autostart:Boolean = false, ms:int = 0, fireOnce:Boolean = false, args:* = null):void
		{
			_tr.registerCallback(callback, autostart, ms, fireOnce, args);
		}
		
		public static function callOnce(callback:Function, ms:int, args:*= null):void
		{
			registerCallback(callback, true, ms, true, args);
		}
		
		public static function stop(callback:Function):void
		{
			_tr.stop(callback);
		}
		
		public static function start(callback:Function):void
		{
			_tr.start(callback);
		}
		
		public static function resetAndStart(callback:Function):void
		{
			_tr.resetAndStart(callback);
		}
		
		public static function unRegisterCallback(callback:Function):void
		{
			_tr.unRegisterCallback(callback);
		}
	}
}