package com.zutalor.synthesizer
{
	import com.noteflight.standingwave3.elements.Sample;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.ShowError;
	import com.zutalor.text.StringUtils;
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.filters.AmpFilter;
	import com.noteflight.standingwave3.filters.PanFilter;
	import com.noteflight.standingwave3.filters.PanFilter;
	import com.noteflight.standingwave3.filters.ResamplingFilter;
	import com.noteflight.standingwave3.generators.ADSREnvelopeGenerator;
	import com.noteflight.standingwave3.generators.SoundGenerator;
	import com.noteflight.standingwave3.utils.AudioUtils;
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
		private static const NUM_SAMPLES_TO_LOAD_CONCURRENTLY:int = 2;
		
		private var _urls:Vector.<String>;
		private var _SamplerSourceGs:Vector.<SamplerSourceG>;
		private var _sampleMaps:gDictionary;
		private var _frequencies:gDictionary;
		
		private var _numSamples:int;
		private var _numLoaded:int;
		private var _curLoading:int;
		private var _SamplerSourceGsLoading:int;
		
		private var _ad:AudioDescriptor;
		private var _onComplete:Function;
		private var _assetPath:String;
				
		public function Voices(sampleRate:int = 44100) 
		{
			_init(sampleRate);
		}
		
		private function _init(sampleRate:int = 44100):void
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
				ShowError.fail(Voices,"synthSounds: sampleMap not found: " + preset.soundName);
			
			freqs = _frequencies.getByKey(preset.soundName);
			url = getSoundUrl(sampleMap, noteNumber);
			indx = _urls.indexOf(url);
			
			freq = freqs[indx];
			noteNumber = noteNumber;
			factor = AudioUtils.noteNumberToFrequency(noteNumber); 
			
			_SamplerSourceGs[indx].frequencyShift = factor / freq;
			audioSource = _SamplerSourceGs[indx].clone();
		
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
			var startLoopFrame:int;
			var endFrame:int;

			//frameCount = audioSource.frameCount;
			//endFrame = loopEnd * _ad.rate;
			//if (endFrame > audioSource.frameCount)
			//	endFrame = audioSource.frameCount;
				trace(audioSource.frameCount);
			//SamplerSourceG(audioSource).endFrame = endFrame;
			//SamplerSourceG(audioSource).startFrame = startLoopFrame = loopStart * _ad.rate;				
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
		
		public function load(xml:XML, assetPath:String = null, onComplete:Function = null):void
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
			
			numSampleMaps = xml.sampleMaps.props.length();	
			for (i = 0; i < numSampleMaps; i++)
			{
				_numSamples += int(xml.sampleMaps.props[i].@samples);	
			}
			_urls = new Vector.<String>(_numSamples);
			_SamplerSourceGs = new Vector.<SamplerSourceG>(_numSamples);
			
			for (var p:int = 0; p < numSampleMaps; p++)
			{
				sampleMap = new SampleMap();
				freqs = new Vector.<Number>;
				
				props = xml.sampleMaps.props[p];
				sampleMap.name = props.@name;
				sampleMap.filebase = props.@filebase;
				sampleMap.fileExt = props.@fileExt;
				sampleMap.baseMidiNote = props.@baseMidiNote;
				sampleMap.interval = props.@interval;
				sampleMap.samples = props.@samples;

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

		// PRIVATE METHODS
		
		private function loadSamples():void
		{
			if (!_urls.length)
				ShowError.fail(Voices,"Synth Sounds: cannot load samples.");
			_numSamples = _urls.length;
			_numLoaded = 0;
			for (var i:int = 0; i < NUM_SAMPLES_TO_LOAD_CONCURRENTLY; i++)
				loadNext();
		}
		
		private function loadNext():void
		{	
			if (_curLoading < _numSamples)
			{
				var sound:Sound = new Sound(new URLRequest(_assetPath + _urls[_curLoading]));
				sound.addEventListener(Event.COMPLETE, onSampleLoadComplete, false, 0, true);
				sound.addEventListener(IOErrorEvent.DISK_ERROR,onIOError, false, 0, true);
				sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				_curLoading++;
			}
		}
		
		private function onIOError(e:Event):void
		{
			trace("IoError");
			ShowError.fail(Voices,"IoError");
		}	
		
		private function onSampleLoadComplete(e:Event):void
		{
			var indx:int;
			
			e.target.removeEventListener(Event.COMPLETE, onSampleLoadComplete);
			e.target.removeEventListener(IOErrorEvent.DISK_ERROR,onIOError);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);			
			indx = _urls.indexOf(StringUtils.getFileName(e.target.url));
			_SamplerSourceGs[indx] = new SamplerSourceG(_ad, new SoundGenerator(e.target as Sound, _ad));
			_numLoaded++;
			if (_numLoaded < _numSamples)
				loadNext();
			else
				if (_onComplete != null)
					_onComplete();				
		}
	}
}