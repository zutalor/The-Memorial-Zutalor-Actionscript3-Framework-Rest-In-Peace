package com.zutalor.media
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;


	public final class MP3Player
	{
		private const bufferSize: int = 4096; 
		private const SAMPLE_RATE:Number = 44.1;	
		
		private var inputSound: Sound = new Sound(); 
		private var outputSound: Sound = new Sound(); 

		private var samplesTotal:int; 	
		private var samplesPosition: int = 0;
		private var enabled: Boolean = false;
		private var _onLoadComplete:Function;
		private var _onPlayComplete:Function;
		private var _loop:Boolean;
		
		public var event:*;
		
		/**
			 Based upon Andre Michelle's MP3Loop
			 * http://blog.andre-michelle.com/2010/playback-mp3-loop-gapless/
		 */
		
		public function MP3Player():void
		{
			outputSound = new Sound();
		}

		public function play(url:String, loop:Boolean = false,  onLoadComplete:Function = null, onPlayComplete:Function = null): void
		{
			_loop = loop;
			inputSound = new Sound();
			inputSound.addEventListener(Event.COMPLETE, loadComplete);
			inputSound.addEventListener(IOErrorEvent.IO_ERROR, mp3Error);
			inputSound.load( new URLRequest(url));
		}
		
		public function stop():void
		{
			outputSound.removeEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
			samplesPosition = 0;
			if (_onPlayComplete != null)
			{
				_onPlayComplete();
				_onPlayComplete = null;
			}			
		}

		private function loadComplete( e:Event ):void
		{
			inputSound.removeEventListener(Event.COMPLETE, loadComplete);
			
			event = e;			
			samplesTotal = inputSound.length * SAMPLE_RATE;
			if (samplesTotal)
			{
				outputSound.addEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
				outputSound.play();
			}
			else
				stop();
				
			if (_onLoadComplete != null)
				_onLoadComplete();					
		}

		private function sampleData( e:SampleDataEvent ):void
		{
			extract( e.data, bufferSize );
		}

		private function extract( target: ByteArray, length:int ):void
		{
			
			while( 0 < length )
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
					samplesPosition = 0;
					if (!_loop)
						stop();
				}
			}
		}

		private function mp3Error( e:IOErrorEvent ):void
		{
			trace( e );
		}
	}
}