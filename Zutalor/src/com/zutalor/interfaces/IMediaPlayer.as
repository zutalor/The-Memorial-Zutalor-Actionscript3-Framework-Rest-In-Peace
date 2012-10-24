package com.zutalor.interfaces
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public interface IMediaPlayer 
	{

		function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		
		function get playerType():String
		
		function set x(n:Number):void
		
		function set y(n:Number):void

		function set name(s:String):void
		
		function get name():String
		
		function get view():DisplayObject
		
		function set width(n:Number):void
		
		function set height(n:Number):void
		
		function get x():Number
		
		function get y():Number
		
		function get width():Number
		
		function get height():Number
		
		function set visible(v:Boolean):void
		
		function get visible():Boolean
		
		function load(url:String, defaultVolume:Number = 1, playerWidth:int = 0, playerHeight:int = 0, scaleToFit:Boolean=true, bufferTime:Number=0):void
		
		function get url():String
		
		function set framerate(fr:Number):void
		
		function get framerate():Number
		
		function set returnToZero(b:Boolean):void
		
		function set totalTime(n:Number):void
		
		function get isPlaying():Boolean
		
		function set volume(v:Number):void
		
		function get volume():Number
		
		function play(viewFadeIn:Number = 0, audioFadeIn:Number = 0, fadeOut:Number = 0, overlap:Number = 0, startDelay:Number = 0, start:Number = 0, end:Number = 0, loop:int = 0, loopDelay:Number = 0):void
		
		function pause():void
		
		function seek(value:Number):void
		
		function stop(fadeOut:Number = 0):void
		
		function dispose():void
	}
}