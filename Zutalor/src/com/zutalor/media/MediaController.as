package com.zutalor.media  
{
	import com.greensock.easing.Sine;
	import com.greensock.loading.core.DisplayObjectLoader;
	import com.greensock.TweenMax;
	import com.zutalor.air.AirStatus;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.StageRef;
	import com.zutalor.utils.TimerRegistery;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MediaController extends EventDispatcher
	{
		public var returnToZeroOnStop:Boolean = true;
		
		private var _view:DisplayObjectContainer;		
		protected var _scaleToFit:Boolean;
		protected var _isPlaying:Boolean;
		protected var _buffering:Boolean;
		
		protected var _url:String;
		protected var _paused:Boolean;
		protected var _duration:Number;
		
		private var _width:Number;
		private var _height:Number;
		
		public function MediaController() 
		{
		
		}
		
		public function load(fileName:String, scaleToFit:Boolean, bufferTime:Number):void
		{
			
		}
		
		public function get visible():Boolean
		{
			return _view.visible;
		}
		
		public function set visible(v:Boolean):void
		{
			_view.visible = v;
		}
		
		public function get hasAudio():Boolean
		{
			return true;
		}
		
		public function set width(n:Number):void
		{
			_view.width = _width = n;
		}
		
		public function set height(n:Number):void
		{
			_view.height = _height = n;
		}
		
		public function get width():Number
		{
			return _width;
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function set x(n:Number):void
		{
			_view.x = n;
		}
		
		public function get x():Number
		{
			return _view.x;
		}

		public function set y(n:Number):void
		{
			_view.y = n;
		}
		
		public function get y():Number
		{
			return _view.y;
		}
		
		public function get view():DisplayObjectContainer
		{
			return _view;
		}
		
		public function set view(v:DisplayObjectContainer):void
		{
			_view = v;
		}
		
		public function set volume(volume:Number):void
		{
			
		}
		
		public function get volume():Number
		{
			return 0;
		}
		
		public function get framerate():Number
		{
			return 0;
		}
		
		public function set framerate(fr:Number):void
		{
			
		}
		
		public function get currentTime():Number
		{
			return 0;
		}
		
		public function set totalTime(n:Number):void
		{
			
		}
		
		public function get totalTime():Number
		{
			return 0;			
		}
		
		public function get percentPlayed():Number
		{
			return 0;			
		}
		
		public function get percentLoaded():Number
		{
			return 0;		
		}
		
		public function get metadata():Object
		{
			return null;
		}
		
		public function get isPlaying():Boolean
		{
			return false;
		}
		
		public function get isBuffering():Boolean
		{
			return _buffering;
		}
		
		public function get isPaused():Boolean
		{
			return false;
		}		
				
		public function play(start:Number = 0):void
		{
			
		}
		
		public function get percentBuffered():Number
		{
			return 0;			
		}		
						
		public function pause():void
		{
			
		}
		
		public function stop():void
		{
			dispatchEvent(new MediaEvent(MediaEvent.STOP));
		}
		
		public function closeStream():void
		{
			
		}
			
		public function onPlaybackComplete(e:Event = null):void
		{
			//trace("MediaControler: play complete", url)
			_isPlaying = false;
			dispatchEvent(new MediaEvent(MediaEvent.COMPLETE));
		}		
					
		public function seek(time:Number):void
		{
			
		}
		
		public function seekToPercent(percent:Number):void
		{
			
		}
		
		public function forward(stepSeconds:Number = 2):void
		{
			
		}
		
		public function rewind(stepSeconds:Number = 2):void
		{
			
		}
				
		public function dispose():void
		{
			//TODO
		}
	}
}