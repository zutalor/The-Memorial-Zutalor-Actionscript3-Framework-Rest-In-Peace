package com.zutalor.utils
{
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Logger
	{
		public static function add(log:String):void
		{
			trace(log);
		}
		
		static public function eTrace(msg:String):void
		{
			eCall("function() {if (console) console.log('" + msg +"')}");
			trace(msg);
		}
		
		private static function eCall(functionCall:String):void
		{
			if( ExternalInterface.available && Capabilities.playerType.toLowerCase()  == "plugin")
				ExternalInterface.call(functionCall);
		}
	}
}