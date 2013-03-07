package com.zutalor.audio
{
	import com.ryanberdeen.soundtouch.SoundTouch;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	public final class SamplePlayer extends EventDispatcher
	{
		private const BLOCK_SIZE: int = 4096;
		private const SAMPLERATE:Number = 44.1;

		private var inputSound:Sound;
		private var outputSound:Sound;
		private var channel:SoundChannel;
		private var onComplete:Function;
		private var onCompleteArgs:*;
		private var embeddedSound:Boolean;
		private var vol:Number;
		private var soundTouch:SoundTouch
		private var filter:SimpleFilter;
		private var samplesTotal:int;
		
		public var soundLoaded:Boolean;
		
		public function SamplePlayer():void
		{
			outputSound = new Sound();
			volume = 1;
			soundTouch = new SoundTouch();
			filter = new SimpleFilter(soundTouch);
		}
		
		public function dispose():void
		{
			inputSound = null;
			outputSound = null;
			channel = null;
			stopSound();
		}
						
		public function set tempo(t:Number):void
		{
			soundTouch.tempo = t;
			filter.onCompleteDelay = 1 / t * 500;
		}
		
		public function get tempo():Number
		{
			return soundTouch.tempo;
		}
		
		public function play(url:String, soundClass:Class = null, onComplete:Function = null, onCompleteArgs:* = null):void
		{
			stopSound();
			soundLoaded = false;
			this.onComplete = onComplete;
			this.onCompleteArgs = onCompleteArgs;
			
			if (channel)
			{
				channel.stop();
				try
				{
					inputSound.close();
				}
				catch (e:Error)
				{
				}
				;
				
				try
				{
					outputSound.close();
				}
				catch (e:Error)
				{
				}
				;
				
			}
			
			if (soundClass)
			{
				soundLoaded = true;
				inputSound = new soundClass();
				inputSound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				channel = inputSound.play();
				channel.addEventListener(Event.SOUND_COMPLETE, onPlaybackComplete, false, 0, true);
			}
			else
			{
				inputSound = new Sound();
				inputSound.addEventListener(Event.COMPLETE, onLoaded, false, 0, true);
				inputSound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				inputSound.load(new URLRequest(url));
			}
		}
		
		public function stop():void
		{
			stopSound();
		}
		
		public function set volume(v:Number):void
		{
			if (channel)
				channel.soundTransform = new SoundTransform(v);
			
			vol = v;
		}
		
		public function get volume():Number
		{
			return vol;
		}
		
		private function onPlaybackComplete(e:Event):void
		{
			stopAndCallOnComplete();
		}
		
		private function stopAndCallOnComplete():void
		{
			stopSound();
	
			if (onComplete != null)
			{
				if (onCompleteArgs)
					onComplete(onCompleteArgs);
				else
					onComplete();
			}
		}
		
		private function stopSound():void
		{
			filter.stop();
		}
		
		private function onLoaded(e:Event = null):void
		{
			removeloadListeners();
			samplesTotal = inputSound.length * SAMPLERATE;
			
			if (samplesTotal)
				channel = filter.play(inputSound, outputSound, stopAndCallOnComplete);
			else
				stopAndCallOnComplete();
		}
		
		private function removeloadListeners():void
		{
			if (inputSound)
			{
				inputSound.removeEventListener(Event.COMPLETE, onLoaded);
				inputSound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
		}
		
		private function onIOError(e:IOErrorEvent):void
		{
			removeloadListeners();
			stopSound();
			dispatchEvent(e);
		}
	}
}