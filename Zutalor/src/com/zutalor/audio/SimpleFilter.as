/*
* SoundTouch AS3 audio processing library
* Copyright (c) Ryan Berdeen (mod by pepos)
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

package com.zutalor.audio {
	import com.greensock.TweenMax;
	import com.ryanberdeen.soundtouch.IFifoSamplePipe;
	import com.zutalor.utils.MasterClock;
	import flash.events.EventDispatcher;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
    import flash.utils.ByteArray;

    public class SimpleFilter extends FilterSupport {
		
		private const BLOCK_SIZE: int = 2048;
		private const SAMPLERATE:Number = 44.1;
		private var sourceSound:Sound;
        private var historyBufferSize:int;
        private var _sourcePosition:int;
        private var outputBufferPosition:int;
        private var _position:int;
		private var samplesTotal:int;
		private var onComplete:Function;
		private var outputSound:Sound;
		private var channel:SoundChannel;
		
		public var onCompleteDelay:int = 700;

        public function SimpleFilter(pipe:IFifoSamplePipe) {
            super(pipe, BLOCK_SIZE);
        }
		
		public function play(sourceSound:Sound, outputSound:Sound, onComplete:Function):SoundChannel
		{
			this.outputSound = outputSound;
			this.sourceSound = sourceSound;
            this.onComplete = onComplete;
			this.historyBufferSize = 22050;
            _sourcePosition = 0;
            outputBufferPosition = 0;
			samplesTotal = (this.sourceSound.length * SAMPLERATE) - 1;
			outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA, handleSampleData, false, 0, true);
			channel = outputSound.play();
			volume = 0;
			TweenMax.to(this, .3, { volume:1 } );
			return channel;
		}
		
		public function set volume(v:Number):void
		{
			channel.soundTransform = new SoundTransform(v);
		}
		
		public function get volume():Number
		{
			return channel.soundTransform.volume;
		}
		
		public function stop():void
		{
			clear();
			if (outputSound)
			{
				MasterClock.unRegisterCallback(callComplete);
				outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, handleSampleData);
			}
		}
		
        public function get position():int {
            return _position;
        }

        public function set position(position:int):void {
            if (position > _position) {
                throw new RangeError('New position may not be greater than current position');
            }
            var newOutputBufferPosition:int = outputBufferPosition - (_position - position);
            if (newOutputBufferPosition < 0) {
                throw new RangeError('New position falls outside of history buffer');
            }
            outputBufferPosition = newOutputBufferPosition;
            _position = position;
        }

        public function get sourcePosition():int {
            return _sourcePosition;
        }

        public function set sourcePosition(sourcePosition:int):void {
            clear();
            _sourcePosition = sourcePosition;
        }

        override protected function fillInputBuffer(numFrames:int):void {
            var bytes:ByteArray = new ByteArray();
            var numFramesExtracted:uint = sourceSound.extract(bytes, numFrames, _sourcePosition);
            _sourcePosition += numFramesExtracted;
			inputBuffer.putBytes(bytes);
        }

        public function extract(target:ByteArray, numFrames:int):int {
			
            fillOutputBuffer(outputBufferPosition + numFrames);

            var numFramesExtracted:int = Math.min(numFrames, outputBuffer.frameCount - outputBufferPosition);
            outputBuffer.extract(target, outputBufferPosition, numFramesExtracted);

            var currentFrames:int = outputBufferPosition + numFramesExtracted;
            outputBufferPosition = Math.min(historyBufferSize, currentFrames);
            outputBuffer.receive(Math.max(currentFrames - historyBufferSize, 0));

            _position += numFramesExtracted;
			
			if (_sourcePosition >= samplesTotal)
			{
				outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, handleSampleData);
				MasterClock.callOnce(callComplete, onCompleteDelay);
			}
            return numFramesExtracted;
        }
		
		private function callComplete():void
		{
			clear();
			onComplete();
		}

        public function handleSampleData(e:SampleDataEvent):void {
			extract(e.data, BLOCK_SIZE);
        }

        override public function clear():void {
            super.clear();
            outputBufferPosition = 0;
        }
    }
}
