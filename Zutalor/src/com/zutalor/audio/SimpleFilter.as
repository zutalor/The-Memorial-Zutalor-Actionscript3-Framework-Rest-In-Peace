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

//Mod by GPepos 3/11/13

package com.zutalor.audio
{
	import com.greensock.TweenMax;
	import com.ryanberdeen.soundtouch.IFifoSamplePipe;
	import com.zutalor.utils.MasterClock;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	
	public class SimpleFilter extends FilterSupport
	{
		
		private const BLOCK_SIZE:int = 2048;
		private const SAMPLERATE:Number = 44.1;
		private var sourceSound:Sound;
		private var historyBufferSize:int;
		private var _sourcePosition:int;
		private var outputBufferPosition:int;
		private var _position:int;
		private var samplesTotal:int;
		private var onComplete:Function;
		private var onRewindBeforeStart:Function;
		private var outputSound:Sound;
		private var channel:SoundChannel;
		private var _paused:Boolean;
		private var pausePosition:int;
		
		public var onCompleteDelay:int = 700;
		public var rewindToStart:Boolean;
		
		public function SimpleFilter(pipe:IFifoSamplePipe)
		{
			super(pipe, BLOCK_SIZE);
		}
		
		public function play(sourceSound:Sound, outputSound:Sound, onComplete:Function, onRewindBeforeStart:Function = null, start:Number = 0):SoundChannel
		{
			this.outputSound = outputSound;
			this.sourceSound = sourceSound;
			this.onComplete = onComplete;
			this.onRewindBeforeStart = onRewindBeforeStart;
			this.historyBufferSize = 22050;
			samplesTotal = (this.sourceSound.length * SAMPLERATE) - 1;
			
			if (start < 0)
				_sourcePosition = samplesTotal - Math.abs(start) * SAMPLERATE * 1000;
			else
				_sourcePosition = start * SAMPLERATE * 1000;
			
			outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA, handleSampleData, false, 0, true);
			channel = outputSound.play();
			volume = 0;
			TweenMax.to(this, .3, {volume: 1});
			_paused = false;
			return channel;
		}
		
		public function get paused():Boolean
		{
			return _paused;
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
			pausePosition = 0;
			if (outputSound)
			{
				MasterClock.unRegisterCallback(callComplete);
				outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, handleSampleData);
			}
		}
		
		public function rewind():void
		{
			var newPosition:int;
			if (_paused)
				pause();
			
			newPosition = sourcePosition - (SAMPLERATE * 1000);
			
			if (newPosition < 0)
			{
				if (onRewindBeforeStart != null)
					onRewindBeforeStart();
				
				sourcePosition = 0;
			}
			else if (rewindToStart)
				sourcePosition = 0;
			else
				sourcePosition = newPosition;
		}
		
		public function pause():void
		{
			if (!_paused)
			{
				_paused = true
				pausePosition = outputBufferPosition;
				channel.stop();
			}
			else
			{
				_paused = false;
				try
				{
					channel = outputSound.play();
				}
				catch (e:Error) { }
				outputBufferPosition = pausePosition;
			}
		}
		
		public function get position():int
		{
			return _position;
		}
		
		public function set position(position:int):void
		{
			
			var newOutputBufferPosition:int
			
			if (position > samplesTotal)
			{
				trace("position is larger than samples total");
			}
			else
			{
				newOutputBufferPosition = outputBufferPosition - (_position - position);
				if (newOutputBufferPosition < 0)
				{
					trace('New position falls outside of history buffer');
				}
				else
				{
					outputBufferPosition = newOutputBufferPosition;
					_position = position;
				}
			}
		}
		
		public function get sourcePosition():int
		{
			return _sourcePosition;
		}
		
		public function set sourcePosition(sourcePosition:int):void
		{
			clear();
			_sourcePosition = sourcePosition;
		}
		
		override protected function fillInputBuffer(numFrames:int):void
		{
			var bytes:ByteArray = new ByteArray();
			var numFramesExtracted:uint = sourceSound.extract(bytes, numFrames, _sourcePosition);
			_sourcePosition += numFramesExtracted;
			inputBuffer.putBytes(bytes);
		}
		
		public function extract(target:ByteArray, numFrames:int):int
		{
			
			var currentFrames:int;
			var numFramesExtracted:int;
			
			fillOutputBuffer(outputBufferPosition + numFrames);
			
			numFramesExtracted = Math.min(numFrames, outputBuffer.frameCount - outputBufferPosition);
			
			outputBuffer.extract(target, outputBufferPosition, numFramesExtracted);
			
			currentFrames = outputBufferPosition + numFramesExtracted;
			outputBufferPosition = Math.min(historyBufferSize, currentFrames);
			outputBuffer.receive(Math.max(currentFrames - historyBufferSize, 0));
			
			_position += numFramesExtracted;
			
			if (_sourcePosition >= samplesTotal)
			{
				_paused = false;
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
		
		public function handleSampleData(e:SampleDataEvent):void
		{
			extract(e.data, BLOCK_SIZE);
		}
		
		override public function clear():void
		{
			super.clear();
			outputBufferPosition = 0;
		}
	}
}
