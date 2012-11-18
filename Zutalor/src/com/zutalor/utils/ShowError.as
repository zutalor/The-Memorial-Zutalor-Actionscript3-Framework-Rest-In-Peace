package com.zutalor.utils 
{
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ShowError 
	{	
		public static function fail(caller:Class = null, message:String = null):void
		{
			var mess:String = getQualifiedClassName(caller) + ": " + message;
			SimpleMessage.show(mess);
			//throw new Error(mess);

		}
	}
}