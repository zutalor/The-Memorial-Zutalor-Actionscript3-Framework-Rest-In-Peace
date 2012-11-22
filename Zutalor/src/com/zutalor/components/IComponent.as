package com.zutalor.components 
{
	import com.zutalor.events.UIEvent;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public interface IComponent 
	{
		function set name(name:String):void
		function dispatchValueChange(uie:UIEvent):void
		function onValueChange(uie:UIEvent):void
		function get value():*
		function set value(value:*):void
	}	
}