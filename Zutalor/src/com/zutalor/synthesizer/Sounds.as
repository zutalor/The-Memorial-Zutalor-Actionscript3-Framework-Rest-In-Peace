package com.zutalor.synthesizer
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.elements.Sample;
	import com.noteflight.standingwave3.filters.AmpFilter;
	import com.noteflight.standingwave3.filters.PanFilter;
	import com.noteflight.standingwave3.filters.ResamplingFilter;
	import com.noteflight.standingwave3.generators.ADSREnvelopeGenerator;
	import com.noteflight.standingwave3.sources.SamplerSource;
	import com.noteflight.standingwave3.utils.AudioUtils;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.synthesizer.properties.SampleMap;
	import com.zutalor.synthesizer.properties.SynthPreset;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.ShowError;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Sounds
	{
	
		protected static var _sampleMaps:PropertyManager;
		protected var soundLoader:SoundLoader;
		protected var presetLoader:PresetLoader;
		protected var assetPath:String;
		protected var ad:AudioDescriptor;
		protected var onComplete:Function;
		
		public static function get sampleMaps():PropertyManager
		{
			return _sampleMaps;
		}
		
		public function Sounds(sampleRate:int = 44100)
		{
			init(sampleRate);
		}
		
		protected function init(sampleRate:int = 44100):void
		{
			ad = new AudioDescriptor(sampleRate, 1);
			soundLoader = new SoundLoader();
			presetLoader = new PresetLoader();
			_sampleMaps = presetLoader.sampleMaps;
		}
		
		public function load(xmlUrl:String, pAssetPath:String, pOnComplete:Function = null):void
		{
			assetPath = pAssetPath;
			onComplete = pOnComplete;
			presetLoader.load(xmlUrl, onPresetLoadComplete);
		}
		
		protected function onPresetLoadComplete():void
		{
			soundLoader.load(_sampleMaps, assetPath, ad, onComplete);
		}
		
		public function getVoice(preset:SynthPreset, noteNumber:Number, eg:ADSREnvelopeGenerator, mods:Array):IAudioSource
		{
			var ampFilter:AmpFilter;
			var audioSource:IAudioSource;
			var indx:int;
			var freq:Number;
			var factor:Number;
			var noteNumber:Number;
			var sampleMap:SampleMap;
			var url:String;
			
			sampleMap = _sampleMaps.getPropsByName(preset.soundName);
			if (!sampleMap)
				ShowError.fail(Sounds, "No samples for " + preset.soundName);
			
			url = getSoundUrl(sampleMap, noteNumber);
			indx = sampleMap.urls.indexOf(url);
			freq = sampleMap.frequencies[indx];
			factor = AudioUtils.noteNumberToFrequency(noteNumber);
			sampleMap.samplerSources[indx].frequencyShift = factor / freq;
			audioSource = sampleMap.samplerSources[indx].clone();
			
			if (preset.loopEnd && preset.loopEnd)
				setupLoop(audioSource, preset.loopStart, preset.loopEnd);
			
			if (mods)
				for (var i:int = 0; i < mods.length; i++)
					SamplerSource(audioSource).pitchModulations.push(mods[i]);
			
			ampFilter = new AmpFilter(audioSource, eg);
			return ampFilter;
		}
		
		protected function getSoundUrl(sampleMap:SampleMap, noteNumber:Number):String
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
		
		protected function setupLoop(audioSource:IAudioSource, loopStart:Number, loopEnd:Number):void
		{
			var startLoopFrame:int;
			var endFrame:int;
			endFrame = loopEnd * ad.rate;
			startLoopFrame = loopStart * ad.rate;
			if (endFrame > audioSource.frameCount)
				endFrame = audioSource.frameCount;
			if (startLoopFrame > endFrame)
				startLoopFrame = 0;
			SamplerSource(audioSource).endFrame = endFrame;
			SamplerSource(audioSource).startFrame = startLoopFrame;
		}
	}
}