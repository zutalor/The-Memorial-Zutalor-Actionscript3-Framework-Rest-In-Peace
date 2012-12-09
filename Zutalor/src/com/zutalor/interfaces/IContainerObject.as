package com.zutalor.interfaces 
{
	/**
	 * ...
	 * @author Geoff
	 */
	public interface IContainerObject 
	{
		function dispose():void
		function recycle():void
		function stop(fadeSeconds:Number = 0):void
		function set enabled(value:Boolean):void
		function get enabled():Boolean
	}
}