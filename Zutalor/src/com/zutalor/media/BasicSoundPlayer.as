package com.zutalor.media 
{
	import com.greensock.TweenMax;
	import com.zutalor.events.MediaEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.*;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class BasicSoundPlayer extends EventDispatcher
	{	
		
		private const _BUFFER_TIME:int = 1000;	
		
		private var _sound:Sound;
		private var _soundContext:SoundLoaderContext;
		private var _channel:SoundChannel;
		private var _soundTransform:SoundTransform;
		private var _volume:Number;
		private var _url:String;
		
		public var onPlaybackCompleteCallback:Function;
		
		public function load(url:String, defaultVolume:Number = 1, playerWidth:int = 0, playerHeight:int = 0, scaleToFit:Boolean = true):void		
		{	
			_url = url;
			_soundContext = new SoundLoaderContext(_BUFFER_TIME);
			_sound = new Sound(new URLRequest(url), _soundContext);
			_volume = defaultVolume;	
			_sound.addEventListener(Event.ID3, function nothing():void {}, false, 0, true);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, callOnIOError, false, 0, true);			
		}
						
		public function closeStream():void
		{
			if (_sound.bytesLoaded < _sound.bytesTotal) 
				_sound.close();
		}		
		
		public function set volume(v:Number):void
		{
			_volume = v;
			if (_channel)
				_channel.soundTransform = new SoundTransform(v);			
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function play(start:Number=0):void
		{
			_soundTransform = new SoundTransform(_volume);
			_channel = _sound.play(0, 0, _soundTransform);			
			_channel.addEventListener(Event.SOUND_COMPLETE, onPlaybackComplete, false, 0, true);			
			_channel = _sound.play(start);
		}

		public function stop(fade:Number=0):void
		{
			if (fade)
				TweenMax.to(this, fade, { volume:0, onComplete:onStopComplete } );
			else
				onStopComplete();
		}
				
		public function dispose():void
		{
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, callOnIOError);
			_sound = null;
			_soundContext = null;
			_soundTransform = null;
			_channel = null;
		}
		
		//PRIVATE METHODS
		
		private function onStopComplete():void
		{
			_channel.stop();			
		}
		
		private function onPlaybackComplete(e:Event = null):void
		{
			if (onPlaybackCompleteCallback != null)
				onPlaybackCompleteCallback(this)
			else	
				dispatchEvent(new MediaEvent(MediaEvent.STOP));				
		}			
		
		private function callOnIOError(e:Event):void
		{
			trace("ioError: " +  _url);
		}
		
	}
}