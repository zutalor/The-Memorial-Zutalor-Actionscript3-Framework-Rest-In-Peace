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
		function set x(n:Number):void
		function set y(n:Number):void
		function get view():DisplayObject
		function set width(n:Number):void
		function set height(n:Number):void
		function get x():Number
		function get y():Number
		function get width():Number
		function get height():Number
		function set visible(v:Boolean):void
		function get visible():Boolean
		function load(url:String, defaultVolume:Number = 1):void
		function get url():String
		function set framerate(fr:Number):void
		function get framerate():Number
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