package com.zutalor.interfaces
{
	import com.zutalor.events.UIEvent;
	import com.zutalor.view.properties.ViewItemProperties;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public interface IComponent
	{
		function set name(name:String):void
		function onValueChange(uie:UIEvent):void
		function get value():*
		function set value(value:*):void
		function render(viewItemProperties:ViewItemProperties = null):void
	}
}