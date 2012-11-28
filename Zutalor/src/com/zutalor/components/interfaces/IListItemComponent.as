package com.zutalor.components.interfaces
{
	import com.zutalor.containers.Container;
	import com.zutalor.events.UIEvent;
	import com.zutalor.view.properties.ViewItemProperties;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public interface IListItemComponent
	{
		function set name(name:String):void
		function dispatchValueChange(uie:UIEvent):void
		function onValueChange(uie:UIEvent):void
		function get value():*
		function set value(value:*):void
		function render(c:Container, width:Number, height:Number):void
	}
}