package com.zutalor.audio
{
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	/**
	 * This file is public domain.
	 *
	 * This class handles changing the frequency and
	 * duration of a sound. Use the speed property
	 * to modify them. You can play a sound slower,
	 * faster, backwards, backwards faster or backwards slower,
	 * so the speed variable can be set to anything you want.
	 *
	 * soyyomakesgames.wordpress.com
	 *
	 * Thanks to McFunkypants for his Pitch_Shift_MP3
	 * class, that served to my game at a start and
	 * inspired this one (in part because I found the
	 * other one hard to modify, as it's code didn't
	 * result very readable to me, as it was uncommented).
	 *
	 * @author soyyo
	 */
	public class FrequencyChangeSound
	{
		private var _input:ByteArray; //the information you brought
		private var looping:Boolean; //wether this sound loops or not
		private var _output:Sound; //the sound that will be played (that will send SampleData events)
		private var _speed:Number; // the speed of the sound
		private var _position:Number; //position (in samples)
		private const BLOCK_SIZE:int = 3072; //The minimum quantity of samples to be written before exiting the onSampleData event.
		private var _volume:Number = 1; // The volume. Its a value between 1 and 0.
		
		/**
		 * The volume of the sound
		 */
		public function get volume():Number
		{
			return _volume;
		}
		
		/**
		 * The volume of this sound.
		 */
		public function set volume(v:Number):void
		{
			_volume = v;
			if (v > 1)
			{
				_volume = 1;
			}
			if (v < 0)
			{
				_volume = 0;
			}
		}
		
		/**
		 * The speed this sound is played at: it can be more or less than 1, or even negative. Default is 1.
		 */
		public function get speed():Number
		{
			return _speed;
		}
		
		/**
		 * The speed this sound is played at: it can be more or less than 1, or even negative. Default is 1.
		 */
		public function set speed(v:Number):void
		{
			_speed = v;
		}
		
		/**
		 * Wether the sound is playing
		 * @return Wether the sound is playing
		 */
		public function isPlaying():Boolean
		{
			return _output.hasEventListener(SampleDataEvent.SAMPLE_DATA);
		}
		
		/**
		 * Stop the sound
		 */
		public function stop():void
		{
			if (isPlaying())
			{
				_output.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			}
		}
		
		/**
		 * A Sound whose playback speed you can change
		 * @param data An instance of ByteArray targeted using Sound.extract(), a Class object representing the sound or a Sound instance.
		 */
		public function FrequencyChangeSound(data:*)
		{
			if (data is Class)
			{
				_input = new ByteArray();
				var snd:Sound = (new (data as Class)) as Sound;
				snd.extract(_input, snd.length * 44.1); //44.1 is the number of samples per milisecond
			}
			else if (data is Sound)
			{
				_input = new ByteArray();
				var snd:Sound = data as Sound;
				snd.extract(_input, snd.length * 44.1); //44.1 is the number of samples per milisecond
			}
			else if (data is ByteArray)
			{
				_input = data as ByteArray;
			}
			else
			{
				throw new Error("An object that isn't a Class or a ByteArray was passed to FrequencyChangeSound");
			}
			_output = new Sound();
			_input.position = 0;
			_position = 0;
		}
		
		/**
		 * Plays the sound.
		 * @param speed The speed the sound should be played from a start
		 * @param loop Wether the Sound should loop or not
		 */
		public function play(speed:Number = 1, loop:Boolean = false):void
		{
			if (!isPlaying())
			{
				looping = loop;
				_speed = speed;
				_output.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				_output.play();
				_input.position = 0;
				if (speed >= 0)
				{
					_position = 0;
				}
				else
				{
					_position = _input.length / 8 - 1;
				}
			}
		}
		
		/**
		 * The onSampleData function that does all the dirty stuff.
		 * @param e The event.
		 */
		private function onSampleData(e:SampleDataEvent):void
		{
			var beginningPos:Number = _position;
			var i:Number = 0;
			if (isPlaying())
			{
				while (i < BLOCK_SIZE) //write until the block is filled
				{
//___________________check if we reached the end of the file
					if (_position < 0)
					{
						if (looping)
						{
							_position += _input.length / 8 - 1; //loops
						}
						else
						{
							stop();
							break;
						}
					}
					if (_position >= _input.length / 8)
					{
						if (looping)
						{
							_position = 0; //loops
						}
						else
						{
							stop();
							break
						}
					}
//____________________get the "indexes" (not the info!) of the two samples that will be blend
					var sample1:int
					var sample2:int;
					if (_speed > 0)
					{
//previous (or actual) sample
						sample1 = Math.floor(_position);
//next sample
						sample2 = sample1 + Math.ceil(_speed);
//if sample2 is out of range, we deal with it
						if (sample2 >= _input.length / 8)
						{
							if (looping)
							{
								sample2 -= _input.length / 8; //loops
							}
							else
							{
								stop();
								break
							}
						}
					}
					if (_speed < 0)
					{
//previous (or actual) sample
						sample1 = Math.ceil(_position);
//next (actually previous) sample
						sample2 = sample1 + Math.floor(_speed);
//if sample2 is out of range, deal with it
						if (sample2 < 0)
						{
							if (looping)
							{
								sample2 += _input.length / 8 - 1; //loops
							}
							else
							{
								stop();
								break;
							}
						}
					}
//_____________________pick the sound information
					_input.position = sample1 * 8; //8 bytes = 1 sample
					var left1:Number = _input.readFloat();
					var right1:Number = _input.readFloat();
					_input.position = sample2 * 8; //8 bytes = 1 sample
					var left2:Number = _input.readFloat();
					var right2:Number = _input.readFloat();
//_____________________get the proportions that will be used to blend the sound information
					var mult1:Number;
					if (_speed > 0)
					{
						mult1 = (_position - sample1) / (sample2 - sample1);
					}
					else
					{
						mult1 = (sample1 - _position) / (sample1 - sample2);
					}
					var mult2:Number = 1 - mult1;
//_____________________write the custom sound information
					e.data.writeFloat((left1 * mult1 + left2 * mult2) * _volume);
					e.data.writeFloat((right1 * mult1 + right1 * mult2) * _volume);
//________________change position
					_position += _speed;
					i += 1;
				}
			}
		}
	}

}