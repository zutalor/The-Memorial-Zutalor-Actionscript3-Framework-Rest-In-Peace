package com.zutalor.components.media.audio 
{
	import com.zutalor.components.media.base.MediaController;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.interfaces.IMediaController;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.EmbeddedResources;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AudioController extends MediaController implements IMediaController
	{		
		private var _sound:Sound;
		private var _soundContext:SoundLoaderContext;
		private var _channel:SoundChannel;
		private var _pausePosition:Number;
		private var _loaded:Boolean;
		private var _volume:Number;
		
		public function AudioController() {}
		
		override public function load(url:String, width:int, height:int, x:int=0, y:int=0):void
		{
			var className:Array;
			
			if (!url)
			{
				onPlaybackComplete();
				return;
			}

			_pausePosition = 0;
			_volume = 1;
			
			if (!bufferTime)
				bufferTime = 1000;

			if (!_loaded)
			{
				_loaded = true;
				_soundContext = new SoundLoaderContext(bufferTime);
			}
			
			if (url.indexOf(".embedded") != -1)
			{
				className = url.split(".");
				_sound = EmbeddedResources.createInstance(className[0]);
			}
			else if (url != _url)
			{
				removeEventListeners();
				if (_channel)
					_channel.stop();
				
				_sound = new Sound(new URLRequest(url), _soundContext);
				_url = url;
				_sound.addEventListener(Event.ID3, onID3Data, false, 0, true);
				_sound.addEventListener(IOErrorEvent.IO_ERROR, callOnIOError, false, 0, true);
			}
			else
				_pausePosition = 0;
		}
		
		override public function get currentTime():Number
		{
			return _channel.position / 1000;
		}
		
		override public function get totalTime():Number
		{
			if (_sound)
			{
				return _sound.length / 1000;
			}
			else
				return 0;
		}
		
		override public function get percentPlayed():Number
		{
			return  _channel.position / _sound.length;			
		}
		
		override public function get percentLoaded():Number
		{
			if (_sound)
				return _sound.bytesLoaded / _sound.bytesTotal;		
			else
				return 0;
		}
		
		override public function get percentBuffered():Number
		{
			return 1; //TODO figure this out			
		}
		
		override public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		override public function get metadata():Object
		{
			return null; //TODO
		}
		
		private function callOnIOError(e:Event):void
		{
			if (!_url)
				trace("ioError: Audio, no url");
			else
				trace("ioError: Audio, " + _url);
			
			onPlaybackComplete(e);
			_sound = null;			
		}
				
		override public function set volume(v:Number):void
		{
			if (_channel)
				_channel.soundTransform = new SoundTransform(v);
			
			_volume = v;
		}
		
		override public function get volume():Number
		{
			return _volume;
		}
		
		override public function play(start:Number = 0):void
		{
			if (_sound)
			{
				_isPlaying = true;
				if (!start)
					_channel = _sound.play(_pausePosition);
				else	
					_channel = _sound.play(start);
				
				if (!_channel.hasEventListener(Event.SOUND_COMPLETE))
				{
					_channel.addEventListener(Event.SOUND_COMPLETE, onPlaybackComplete, false, 0, true);
					_channel.soundTransform = new SoundTransform(_volume);
				}
				MasterClock.registerCallback(checkStart, true, 100);
			}
			else
				onPlaybackComplete();
		}
		
		private function checkStart():void
		{
			if (_sound && _sound.length)
			{
				MasterClock.unRegisterCallback(checkStart);
				dispatchEvent(new MediaEvent(MediaEvent.PLAY));
			}
			else if (!_sound)
				MasterClock.unRegisterCallback(checkStart);			
			
		}
		
		private function onID3Data(e:Event):void
		{
			
		}
		
		override public function onPlaybackComplete(e:Event=null):void
		{
			_isPlaying = false;
			super.onPlaybackComplete(e);
		}
			
		override public function pause():void
		{
			_isPlaying = false;
			super.pause();
			_pausePosition = _channel.position;
			_channel.stop();
		}
		
		override public function stop():void
		{
			if (_sound)
			{
				_isPlaying = false;	
				super.stop();
				if (_channel)
					_channel.stop();
			
				if (_sound.bytesLoaded < _sound.bytesTotal)
					_sound.close();

				_pausePosition = 0;
			}
		}

				
		override public function seek(seekTime:Number):void
		{
			if (_sound)
			{
				_channel.stop();
				_pausePosition = seekTime;
				_channel = _sound.play(_pausePosition);
			}
		}
		
		override public function seekToPercent(percent:Number):void
		{
			if (_sound)
			{
				_channel.stop();
				_pausePosition = _sound.length * percent;
				_channel = _sound.play(_pausePosition);
			}
		}
		
		private function removeEventListeners():void
		{
			if (_sound)
			{
				_sound.removeEventListener(Event.ID3, onID3Data);
				_sound.removeEventListener(IOErrorEvent.IO_ERROR, callOnIOError);
			}
			if (_channel)
				_channel.removeEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);			
		}
		
		override public function dispose():void
		{
			removeEventListeners();
			_sound = null;
			_soundContext = null;
			_channel = null;
		}
	}
}