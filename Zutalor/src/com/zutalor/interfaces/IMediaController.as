package com.zutalor.interfaces 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public interface IMediaController
	{			
		function load(fileName:String, scaleToFit:Boolean, bufferTime:Number):void
		
		function set view(v:DisplayObjectContainer):void
		
		function get view():DisplayObjectContainer
		
		function set x(n:Number):void
		
		function set y(n:Number):void
		
		function set width(n:Number):void
		
		function set height(n:Number):void
		
		function get x():Number
		
		function get y():Number
		
		function get width():Number
		
		function get height():Number
		
		function set visible(v:Boolean):void
		
		function get visible():Boolean
		
		function get currentTime():Number
		
		function get totalTime():Number
		
		function get percentPlayed():Number
		
		function get percentLoaded():Number
		
		function get percentBuffered():Number
		
		function get hasAudio():Boolean
		
		function get volume():Number
		
		function set volume(volume:Number):void
		
		function set framerate(fr:Number):void
		
		function get framerate():Number
		
		function get metadata():Object												
		
		function get isPlaying():Boolean
		
		function get isPaused():Boolean
						
		function play(start:Number = 0):void
						
		function pause():void
		
		function stop():void
		
		function closeStream():void
		
		function onPlaybackComplete(e:Event = null):void
				
		function seek(time:Number):void
		
		function seekToPercent(percent:Number):void
		
		function forward(stepSeconds:Number = 2):void
		
		function rewind(stepSeconds:Number = 2):void
				
		function dispose():void
	}
}