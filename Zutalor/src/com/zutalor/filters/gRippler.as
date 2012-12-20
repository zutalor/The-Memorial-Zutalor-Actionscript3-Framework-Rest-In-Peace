package com.zutalor.filters  
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class gRippler extends Rippler
	{
		private var _fadeTime:int;
		private var _stopTime:int;
		private var _source:DisplayObject;
		
		public function gRippler(source:DisplayObject, strength:Number, scaleX:Number = 2, scaleY:Number = 2, fadeTimeSecs:Number=4) 
		{
			super(source, strength, scaleX, scaleY);
			_source = source;
			_fadeTime = fadeTimeSecs * 1000;
			source.removeEventListener(Event.ENTER_FRAME, handleEnterFrame); // we don't need to render if nothing is moving...eating up cpu cycles.
		}
		
		public function render(x:int, y:int, size:int = 20, alpha:Number = 1):void
		{
			drawRipple(x, y, size, alpha);
			_stopTime = getTimer() + _fadeTime;
			
			handleEnterFrame(null);
			if (!_source.hasEventListener(Event.ENTER_FRAME))
				_source.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function dispose():void
		{
			_source.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			destroy();
		}
		
		private function onEnterFrame(e:Event):void
		{
			if (getTimer() < _stopTime)
				handleEnterFrame(e);
			else
				_source.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}