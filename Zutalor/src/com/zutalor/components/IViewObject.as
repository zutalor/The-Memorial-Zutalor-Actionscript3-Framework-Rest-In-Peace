package com.zutalor.components 
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
		function stop():void
		function set enabled(value:Boolean):void
		function get enabled():Boolean
	}
}