package com.zutalor.synthesizer
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.filters.AmpFilter;
	import com.noteflight.standingwave3.filters.PanFilter;
	import com.noteflight.standingwave3.filters.ResamplingFilter;
	import com.noteflight.standingwave3.generators.ADSREnvelopeGenerator;
	import com.noteflight.standingwave3.generators.SoundGenerator;
	import com.noteflight.standingwave3.utils.AudioUtils;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.text.StringUtils;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.MathG;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Voices
	{
		protected static const NUM_SAMPLES_TO_LOAD_CONCURRENTLY:int = 2;
		
		protected var _urls:Vector.<String>;
		protected var _samplerSources:Vector.<SamplerSourceG>;
		protected var _sampleMaps:gDictionary;
		protected var _frequencies:gDictionary;
		
		protected var _numSamples:int;
		protected var _numLoaded:int;
		protected var _curLoading:int;
		protected var _samplerSourcesLoading:int;
		
		protected var _ad:AudioDescriptor;
		protected var _onComplete:Function;
		protected var _assetPath:String;
		
		public function Voices(sampleRate:int = 44100)
		{
			_init(sampleRate);
		}
		
		protected function _init(sampleRate:int = 44100):void
		{
			_ad = new AudioDescriptor(sampleRate, 1);
			_sampleMaps = new gDictionary;
			_frequencies = new gDictionary;
		}
		
		public function get audioDescriptor():AudioDescriptor
		{
			return _ad;
		}
		
		public function getVoice(preset:SynthPreset, noteNumber:Number, eg:ADSREnvelopeGenerator, mods:Array):ResamplingFilter
		{
			var ampFilter:AmpFilter;
			var audioSource:IAudioSource;
			var indx:int;
			var freq:Number;
			var factor:Number;
			var noteNumber:Number;
			var sampleMap:SampleMap;
			var freqs:Vector.<Number>;
			var url:String;
			var panFilter:PanFilter;
			var resamplingFilter:ResamplingFilter;
			
			sampleMap = _sampleMaps.getByKey(preset.soundName);
			if (!sampleMap)
				throw new Error("synthSounds: sampleMap not found: " + preset.soundName);
			
			freqs = _frequencies.getByKey(preset.soundName);
			url = getSoundUrl(sampleMap, noteNumber);
			indx = _urls.indexOf(url);
			
			freq = freqs[indx];
			noteNumber = noteNumber;
			factor = AudioUtils.noteNumberToFrequency(noteNumber);
			
			_samplerSources[indx].frequencyShift = factor / freq;
			audioSource = _samplerSources[indx].clone();
			
			if (preset.start)
				SamplerSourceG(audioSource).firstFrame = preset.start;
			
			if (preset.loopEnd)
				setupLoop(audioSource, preset.loopStart, preset.loopEnd);
			
			if (mods)
				for (var i:int = 0; i < mods.length; i++)
					SamplerSourceG(audioSource).pitchModulations.push(mods[i]);
			
			panFilter = new PanFilter(new AmpFilter(audioSource, eg), preset.pan, preset.gain);
			resamplingFilter = new ResamplingFilter(panFilter);
			
			return resamplingFilter;
		
		}
		
		public function setupLoop(audioSource:IAudioSource, loopStart:Number, loopEnd:Number):void
		{
			
			var frameCount:int;
			var isNegative:Boolean;
			var test:Vector.<Number>;
			var startLoopFrame:int;
			var endFrame:int;
			
//find zero crossing frame or close to it...if zero is crossed between frames.
//var sample:Sample;
			
			/*
			   frameCount = audioSource.frameCount;
			   sample = audioSource.getSample(frameCount); // be faster to just get an offest into...but whatever for now. (too slow!)
			   endFrame = loopEnd * _ad.rate;
			   if (endFrame > audioSource.frameCount)
			   endFrame = audioSource.frameCount;
			
			   for (var i:int = startLoopFrame; i < audioSource.frameCount; i++)
			   {
			   test = sample.getChannelSlice(0, i, 2);
			   if (!test[0])
			   {
			   startLoopFrame = i;
			   break;
			   }
			   else
			   {
			   if (test[0] < 0)
			   isNegative = true;
			   if (isNegative && test[1] > 0 || !isNegative && test[1] < 0)
			   {
			   startLoopFrame = i;
			   break;
			   }
			   }
			   }
			   isNegative = false;
			   for (i = endFrame; i > 0; i--)
			   {
			   test = sample.getChannelSlice(0, i-1, 2);
			   if (!test[1])
			   {
			   endFrame = i;
			   break;
			   }
			   else
			   {
			   if (test[1] < 0)
			   isNegative = true;
			   if (isNegative && test[0] > 0 || !isNegative && test[0] < 0)
			   {
			   endFrame = i;
			   break;
			   }
			   }
			   }
			 */
			SamplerSourceG(audioSource).endFrame = endFrame;
			SamplerSourceG(audioSource).startFrame = startLoopFrame = loopStart * _ad.rate;
		}
		
		public function getSoundUrl(sampleMap:SampleMap, noteNumber:Number):String
		{
			var n:int;
			var totalNotes:int;
			
			if (noteNumber <= sampleMap.baseMidiNote)
				n = 0;
			else
			{
				totalNotes = (sampleMap.samples * sampleMap.interval) + sampleMap.baseMidiNote;
				if (noteNumber > totalNotes)
					n = sampleMap.samples - 1;
				else
					n = Math.round(MathG.linearConversion(noteNumber, sampleMap.baseMidiNote, totalNotes, 0, sampleMap.samples));
			}
			if (n == sampleMap.samples)
				n = sampleMap.samples - 1;
			
			if (n < 9)
				return sampleMap.filebase + "-0" + (n + 1) + sampleMap.fileExt;
			else
				return sampleMap.filebase + "-" + (n + 1) + sampleMap.fileExt;
		}
		
		public function load(sampleMaps:PropertyManager, assetPath:String = null, onComplete:Function = null):void
		{
			var numSampleMaps:int;
			var sampleMap:SampleMap;
			var props:XML;
			var fileName:String;
			var i:int;
			var curSample:int;
			var freqs:Vector.<Number>;
			
			_assetPath = assetPath;
			_onComplete = onComplete;
			
			numSampleMaps = sampleMaps.length;
			for (i = 0; i < numSampleMaps; i++)
			{
				sampleMap = sampleMaps.getPropsByIndex(i);
				_numSamples += sampleMap.samples;
			}
			_urls = new Vector.<String>(_numSamples);
			_samplerSources = new Vector.<SamplerSourceG>(_numSamples);
			
			for (var p:int = 0; p < numSampleMaps; p++)
			{
				sampleMap = sampleMaps.getPropsByIndex(p);
				freqs = new Vector.<Number>;
				
				for (i = 1; i <= sampleMap.samples; i++)
				{
					if (i < 10)
						fileName = sampleMap.filebase + "-0" + i + sampleMap.fileExt;
					else
						fileName = sampleMap.filebase + "-" + i + sampleMap.fileExt;
					
					_urls[curSample] = fileName;
					freqs[curSample] = AudioUtils.noteNumberToFrequency((sampleMap.interval * i) + sampleMap.baseMidiNote);
					curSample++;
				}
				_frequencies.insert(sampleMap.name, freqs);
				_sampleMaps.insert(sampleMap.name, sampleMap);
			}
			loadSamples();
		}
		
// PROTECTED METHODS
		
		protected function loadSamples():void
		{
			if (!_urls.length)
				throw new Error("Synth Sounds: cannot load samples.");
			_numSamples = _urls.length;
			_numLoaded = 0;
			for (var i:int = 0; i < NUM_SAMPLES_TO_LOAD_CONCURRENTLY; i++)
				loadNext();
		}
		
		protected function loadNext():void
		{
			if (_curLoading < _numSamples)
			{
				var sound:Sound = new Sound(new URLRequest(_assetPath + _urls[_curLoading]));
				sound.addEventListener(Event.COMPLETE, onSampleLoadComplete, false, 0, true);
				sound.addEventListener(IOErrorEvent.DISK_ERROR, onIOError, false, 0, true);
				sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				_curLoading++;
			}
		}
		
		protected function onIOError(e:Event):void
		{
			trace("IoError");
			throw new Error("IoError");
		}
		
		protected function onSampleLoadComplete(e:Event):void
		{
			var indx:int;
			
			e.target.removeEventListener(Event.COMPLETE, onSampleLoadComplete);
			e.target.removeEventListener(IOErrorEvent.DISK_ERROR, onIOError);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			indx = _urls.indexOf(StringUtils.getFileName(e.target.url));
			_samplerSources[indx] = new SamplerSourceG(_ad, new SoundGenerator(e.target as Sound, _ad));
			_numLoaded++;
			if (_numLoaded < _numSamples)
				loadNext();
			else if (_onComplete != null)
				_onComplete();
		}
	}
}