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
		private const bufferSize: int = 4096; 
		private const SAMPLERATE:Number = 44.1;	
		
		private var inputSound: Sound; 
		private var outputSound: Sound = new Sound(); 

		private var samplesTotal:int; 	
		private var samplesPosition: int = 0;
		private var enabled: Boolean = false;
		private var onComplete:Function;
		private var loop:Boolean;
		private var playing:Boolean;
		
		public var soundLoaded:Boolean;
		
		/*
			* ...
			* @author Geoff Pepos
		*/
		
		public function SamplePlayer():void
		{
			outputSound = new Sound();
		}

		public function play(url:String, loop:Boolean = false, onComplete:Function = null): void
		{
			stopSound();
			loop = loop;
			onComplete = onComplete;
			inputSound = new Sound();
			inputSound.addEventListener(Event.COMPLETE, onLoaded);
			inputSound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			inputSound.load(new URLRequest(url));
		}
		
		public function stop():void
		{
			stopSound();
			if (onComplete != null)
				onComplete();
				
		}
		
		private function stopSound():void
		{
			if (playing)
			{
				playing = false;
				removeInputListeners();
				inputSound = null;
				outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, sampleData);								
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
				outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleData);
				outputSound.play();
			}
			else
			{
				soundLoaded = false;
				stop();	
			}
		}
		
		private function removeInputListeners():void
		{
			if (inputSound)
			{
				inputSound.removeEventListener(Event.COMPLETE, onLoaded);
				inputSound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
		}

		private function sampleData(e:SampleDataEvent):void
		{
			extract(e.data, bufferSize);
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
					inputSound.extract( target, length, samplesPosition);
					samplesPosition += length;
					length = 0;
				}

				if (samplesPosition == samplesTotal)
				{
					if (!loop)
						stop();
					else
						samplesPosition = 0;
				}
			}
		}

		private function onIOError( e:IOErrorEvent ):void
		{
			trace( e );
			stop();
		}
	}
}