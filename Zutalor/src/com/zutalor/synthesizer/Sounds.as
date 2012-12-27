package com.zutalor.synthesizer
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.filters.AmpFilter;
	import com.noteflight.standingwave3.filters.PanFilter;
	import com.noteflight.standingwave3.filters.ResamplingFilter;
	import com.noteflight.standingwave3.generators.ADSREnvelopeGenerator;
	import com.noteflight.standingwave3.sources.SamplerSource;
	import com.noteflight.standingwave3.utils.AudioUtils;
	import com.zutalor.synthesizer.properties.SoundProperties;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.ShowError;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Sounds
	{
	
		protected var sounds:gDictionary;
		protected var soundLoader:SoundLoader;
		protected var ad:AudioDescriptor;
		protected var onComplete:Function;
		
		
		public function Sounds(sampleRate:int = 44100)
		{
			init(sampleRate);
		}
		
		protected function init(sampleRate:int = 44100):void
		{
			ad = new AudioDescriptor(sampleRate, 1);
			sounds = new gDictionary;
		}
		
		public function loadSounds(assetPath:String = null, onComplete:Function = null):void
		{
			soundLoader.load(sounds, assetPath, onComplete);
		}
		
		public function getVoice(preset:SynthPreset, noteNumber:Number, eg:ADSREnvelopeGenerator, mods:Array):ResamplingFilter
		{
			var ampFilter:AmpFilter;
			var audioSource:IAudioSource;
			var indx:int;
			var freq:Number;
			var factor:Number;
			var noteNumber:Number;
			var soundProperties:SoundProperties;
			var url:String;
			var panFilter:PanFilter;
			var resamplingFilter:ResamplingFilter;
			
			soundProperties = sounds.getByKey(preset.soundName);
			
			sampleMap = sampleMaps.getByKey(preset.soundName);
			if (!sounds)
				ShowError.fail(Sounds, "Sound not found: " + preset.soundName);
			
			url = getSoundUrl(soundProperties.sampleMap, noteNumber);
			indx = soundProperties.urls.indexOf(url);
			freq = soundProperties.frequencies[indx];
			factor = AudioUtils.noteNumberToFrequency(noteNumber);
			soundProperties.samplerSources[indx].frequencyShift = factor / freq;
			audioSource = soundProperties.samplerSources[indx].clone();
						
			if (preset.loopEnd && preset.loopEnd)
				setupLoop(audioSource, preset.loopStart, preset.loopEnd);
			
			if (mods)
				for (var i:int = 0; i < mods.length; i++)
					SamplerSource(audioSource).pitchModulations.push(mods[i]);
			
			panFilter = new PanFilter(new AmpFilter(audioSource, eg), preset.pan, preset.gain);
			resamplingFilter = new ResamplingFilter(panFilter);
			
			return resamplingFilter;
		
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
		
		protected function setupLoop(audioSource:IAudioSource, loopStart:Number, loopEnd:Number):void
		{
			var startLoopFrame:int;
			var endFrame:int;

			// maybe find zero crossing?
			
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