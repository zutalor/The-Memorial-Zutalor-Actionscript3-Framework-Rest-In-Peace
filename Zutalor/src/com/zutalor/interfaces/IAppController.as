package com.zutalor.interfaces 
{
	import com.zutalor.view.ViewController;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.NetStatusEvent;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public interface IAppController
	{
		function init(params:Object):void
		function getValueObject(params:Object = null):*
		function exit():void
		function dispose():void
		function onModelError(args:* = null):void
		function onModelChange(responds:* = null):void
		function valueUpdated(params:*):void
		function onSearchKey():void
		function onMenuKey():void
		function onBackKey():void
		function onDeactivate(e:Event):void
		function onExiting(e:Event):void
		function onItemFocusIn(params:*):void
	}
}