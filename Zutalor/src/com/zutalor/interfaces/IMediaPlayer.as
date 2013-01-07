package com.zutalor.interfaces
{
	import flash.display.DisplayObject;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public interface IMediaPlayer 
	{
		function get playerType():String	
		function get view():DisplayObject
		function set visible(v:Boolean):void
		function get visible():Boolean
		function load(url:String, width:int, height:int, x:int=0, y:int=0):void
		function get url():String
		function set returnToZero(b:Boolean):void
		function set totalTime(n:Number):void
		function get isPlaying():Boolean
		function set volume(v:Number):void
		function get volume():Number
		function play():void
		function pause():void
		function seek(value:Number):void
		function stop(fadeOut:Number = 0):void
		function dispose():void
	}
}