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
			throw new Error(getQualifiedClassName(caller) + ": " + message);
		}
	}
}