package com.zutalor.audio
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;


	public final class SamplePlayer
	{
		public var speed:int
		private static var bufferSkipCount:int;
		
		private const bufferSize: int = 4096; 
		private const SAMPLERATE:Number = 44.1;	
		private var inputSound: Sound; 
		private var outputSound: Sound = new Sound(); 
		private var samplesTotal:int; 	
		private var samplesPosition: int = 0;
		private var onComplete:Function;
		private var onCompleteArgs:*;
		private var playing:Boolean;
		
		public var soundLoaded:Boolean;
		
		/*
			* @author inspired by MP3Loop.as by andre.michelle@audiotool.com (04/2010) 
			* @author revised and extended by Geoff Pepos (11/2012)
			* http://blog.andre-michelle.com/2010/playback-mp3-loop-gapless/
		*/
		
		public function SamplePlayer():void
		{
			outputSound = new Sound();
		}

		public function play(url:String, onComplete:Function = null, onCompleteArgs:*=null): void
		{
			stopSound();
			soundLoaded = false;
			this.onComplete = onComplete;
			this.onCompleteArgs = onCompleteArgs;
			inputSound = new Sound();
			inputSound.addEventListener(Event.COMPLETE, onLoaded, false, 0, true);
			inputSound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			inputSound.load(new URLRequest(url));
		}
		
		public function stop():void
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
			if (playing)
			{
				playing = false;
				removeInputListeners();
				inputSound = null;
				outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);								
				samplesPosition = 0;
			}		
		}

		private function onLoaded( e:Event ):void
		{
			playing = true;	
			removeInputListeners();		
			samplesTotal = inputSound.length * SAMPLERATE;
			
			if (samplesTotal)
			{
				soundLoaded = true;
				outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				outputSound.play();
			}
			else

				stop();	
		}
		
		private function onSampleData(e:SampleDataEvent):void
		{	
			extract(e.data, bufferSize);
		}		
		
		private function removeInputListeners():void
		{
			if (inputSound)
			{
				inputSound.removeEventListener(Event.COMPLETE, onLoaded);
				inputSound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
		}

		private function extract(target: ByteArray, length:int):void
		{
			while( 0 < length && playing )
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

				if (samplesPosition == samplesTotal)
					stop();
			}
		}

		private function onIOError( e:IOErrorEvent ):void
		{
			trace( e );
			stop();
		}
	}
}