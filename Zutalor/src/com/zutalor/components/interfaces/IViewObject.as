package com.zutalor.components.interfaces 
{
	import com.zutalor.properties.ViewItemProperties;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public interface IViewObject 
	{
		function dispose():void
		function recycle():void
		function stop(fadeSeconds:Number = 0):void
		function set enabled(value:Boolean):void
		function get enabled():Boolean
	}
}