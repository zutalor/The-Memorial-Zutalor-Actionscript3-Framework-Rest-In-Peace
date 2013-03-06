package com.zutalor.audio
{
	import com.zutalor.utils.MasterClock;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;


	public final class SamplePlayer extends EventDispatcher
	{
		public var speed:int;
	
		private const SAMPLERATE:Number = 44.1;
		private var bufferSize: int;
		private var inputSound: Sound;
		private var outputSound: Sound;
		private var channel:SoundChannel;
		private var samplesTotal:int;
		private var samplesPosition: int = 0;
		private var onComplete:Function;
		private var onCompleteArgs:*;
		private var playing:Boolean;
		private var embeddedSound:Boolean;
		private var vol:Number;
		
		public var soundLoaded:Boolean;
		
		/*
			* @author inspired by MP3Loop.as by andre.michelle@audiotool.com (04/2010)
			* @author revised and extended by Geoff Pepos (11/2012)
			* http://blog.andre-michelle.com/2010/playback-mp3-loop-gapless/
		*/
		
		public function SamplePlayer(bufferSize:int = 4096):void
		{
			this.bufferSize = bufferSize;
			outputSound = new Sound();
			vol = 1;
		}

		public function dispose():void
		{
			inputSound = null;
			outputSound = null;
			channel = null;
			stopSound();
		}
		
		public function play(url:String, soundClass:Class = null, onComplete:Function = null, onCompleteArgs:*=null): void
		{
			stopSound();
			soundLoaded = false;
			this.onComplete = onComplete;
			this.onCompleteArgs = onCompleteArgs;
			
			if (channel)
			{
				channel.stop();
				
				try {
					inputSound.close();
				} catch (e:Error) { };

				try {
					outputSound.close();
				} catch (e:Error) { };
				
			}
				
			if (soundClass)
			{
				inputSound = new soundClass();
				onLoaded();
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
				MasterClock.callOnce(callOnComplete, 225) // TODO tie this to the sample rate and buffer size.
				
			function callOnComplete():void
			{
				if (onComplete != null)
				{
					if (onCompleteArgs)
						onComplete(onCompleteArgs);
					else
						onComplete();
				}
			}
		}
		
		private function stopSound():void
		{
			if (playing)
			{
				playing = false;
				outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				samplesPosition = 0;
			}
		}

		private function onLoaded( e:Event = null ):void
		{
			removeloadListeners();
			samplesTotal = inputSound.length * SAMPLERATE;
			
			if (samplesTotal)
			{
				playing = true;
				soundLoaded = true;
				outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				channel = outputSound.play();
				volume = vol;
			}
			else
				stopAndCallOnComplete();
		}
		
		private function onSampleData(e:SampleDataEvent):void
		{
			if (playing)
				extract(e.data, bufferSize);
		}
		
		private function removeloadListeners():void
		{
			if (inputSound)
			{
				inputSound.removeEventListener(Event.COMPLETE, onLoaded);
				inputSound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
		}

		private function extract(target: ByteArray, length:int):void
		{
			var amplitude:Number;
			
			while(playing && 0 < length)
			{
				if (samplesPosition + length > samplesTotal)
				{
					var read: int = samplesTotal - samplesPosition;
					inputSound.extract( target, read, samplesPosition);
					samplesPosition += read;
					length -= read;
				}
				else
				{
					inputSound.extract(target, length, samplesPosition);
					samplesPosition += length;
					length = 0;
				}
				samplesPosition += speed;
				
				if (samplesPosition >= samplesTotal)
					stopAndCallOnComplete();
			}
		}

		private function onIOError( e:IOErrorEvent ):void
		{
			removeloadListeners();
			stopSound();
			dispatchEvent(e);
		}
	}
}