package com.zutalor.media
{

	/**
	 * Playback MP3-Loop (gapless)
	 *
	 * This source code enable sample exact looping of MP3.
	 * 
	 * http://blog.andre-michelle.com/2010/playback-mp3-loop-gapless/
	 *
	 * Tested with samplingrate 44.1 KHz
	 *
	 * <code>MAGIC_DELAY</code> does not change on different bitrates.
	 * Value was found by comparision of encoded and original audio file.
	 *
	 * @author andre.michelle@audiotool.com (04/2010)
	 */

	public final class MP3Player extends Sprite
	{
		private const MAGIC_DELAY:Number = 2257.0; // LAME 3.98.2 + flash.media.Sound Delay
		private const bufferSize: int = 4096; // Stable playback
		private const samplesTotal: int = 124417; // original amount of sample before encoding (change it to your loop)
		private const mp3: Sound = new Sound(); // Use for decoding
		private const out: Sound = new Sound(); // Use for output stream
		private var samplesPosition: int = 0;
		private var enabled: Boolean = false;
		private var _onLoadComplete:Function;
		private var _onPlayComplete:Function;
		
		public var data:*;

		private function play(url:String, onLoadComplete:Function = null, onPlayComplete:Function = null): void
		{
			mp3.addEventListener( Event.COMPLETE, loadComplete );
			mp3.addEventListener( IOErrorEvent.IO_ERROR, mp3Error );
			mp3.load( new URLRequest( url ) );
		}

		private function loadComplete( e:Event ):void
		{
			if (_onLoadComplete != null)
				_onLoadComplete();
			
			samplesTotal = mp3.bytesLoaded;
			data = e.target.data;
			out.addEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
			enabled = true;
			out.play();
		}

		private function sampleData( e:SampleDataEvent ):void
		{
			if( enabled )
				extract( e.data, bufferSize );
			else
				silent( e.data, bufferSize );
		}

		/**
		 * This methods extracts audio data from the mp3 and wraps it automatically with respect to encoder delay
		 *
		 * @param target The ByteArray where to write the audio data
		 * @param length The amount of samples to be read
		 */
		private function extract( target: ByteArray, length:int ):void
		{
			while( 0 < length )
			{
				if( samplesPosition + length > samplesTotal )
				{
					var read: int = samplesTotal - samplesPosition;
					mp3.extract( target, read, samplesPosition + MAGIC_DELAY );
					samplesPosition += read;
					length -= read;
				}
				else
				{
					mp3.extract( target, length, samplesPosition + MAGIC_DELAY );
					samplesPosition += length;
					length = 0;
				}

				if( samplesPosition == samplesTotal ) // END OF LOOP > WRAP
				{
					out.removeEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
					if (_onPlayComplete != null)
						_onPlayComplete();
						
					samplesPosition = 0;
				}
			}
		}

		private function silent( target:ByteArray, length:int ):void
		{
			target.position = 0;

			while( length-- )
			{
				target.writeFloat( 0.0 );
				target.writeFloat( 0.0 );
			}
		}

		private function mp3Error( e:IOErrorEvent ):void
		{
			trace( e );
		}

		public override function toString():String
		{
			return '[SandboxMP3Cycle]';
		}
	}
}