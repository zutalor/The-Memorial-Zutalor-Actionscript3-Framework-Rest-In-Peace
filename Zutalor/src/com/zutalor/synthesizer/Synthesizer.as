package com.zutalor.synthesizer
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.filters.ResamplingFilter;
	import com.noteflight.standingwave3.generators.ADSREnvelopeGenerator;
	import com.noteflight.standingwave3.modulation.BendModulation;
	import com.noteflight.standingwave3.output.AudioPlayer;
	import com.noteflight.standingwave3.utils.AudioUtils;
	import com.zutalor.utils.gDictionary;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Synthesizer
	{
		public var voices:Voices;
		public var presets:SynthPresets;
		public var sequencer:Sequencer;
		public var tracks:gDictionary;
		
		private var audioPlayers:Vector.<AudioPlayer>;
		private var envelopeGenerators:Vector.<ADSREnvelopeGenerator>;
		private var curVoice:int;
		private var framesPerCallBack:int;
		private var sampleRate:int;
		private var monoAD:AudioDescriptor;
		private var stereoAD:AudioDescriptor;
		private var maxVoices:int;
			
		public function Synthesizer(pSampleRate:Number, pFramesPerCallBack:int, pMaxVoices:int = 16)
		{
			framesPerCallBack = pFramesPerCallBack;
			sampleRate = pSampleRate;
			maxVoices = pMaxVoices;
			init();
		}	
		
		private function init():void
		{
			voices = new Voices(sampleRate);
			presets = new SynthPresets();
			tracks = new gDictionary();
			sequencer = new Sequencer(voices, presets, tracks, framesPerCallBack, sampleRate);
			monoAD = new AudioDescriptor(sampleRate, 1);
			stereoAD = new AudioDescriptor(sampleRate, 2);
			audioPlayers = new Vector.<AudioPlayer>;
			envelopeGenerators = new Vector.<ADSREnvelopeGenerator>(maxVoices);
			for (var i:int = 0; i < maxVoices; i++)
				audioPlayers[i] = new AudioPlayer(framesPerCallBack);
		}
		
		public function playNote(note:Number, preset:SynthPreset):void
		{
			var bm:BendModulation;
			var mods:Array;
			var voice:ResamplingFilter;	

			if (preset.bendEndTime)
			{
				bm = new BendModulation(preset.bendStartTime, preset.bendStartValue, preset.bendEndTime, preset.bendEndValue);
				mods = [ bm ];
			}
				
			if (!preset.midiNoteNumbers)
				note = AudioUtils.frequencyToNoteNumber(note);

			if (preset.rounding)
				note = Math.round(note);
		
			if (envelopeGenerators[curVoice])	
			{
				envelopeGenerators[curVoice].destroy();
			}	
			if (preset.monophonic)
				for (var i:int = 0; i < curVoice; i++)
					if (preset.name && audioPlayers[i].preset == preset.name)
						audioPlayers[i].stop();
			
			envelopeGenerators[curVoice] = new ADSREnvelopeGenerator(monoAD, preset.attack, preset.decay, preset.hold, preset.sustain, preset.release);	
			
			voice = voices.getVoice(preset, note, envelopeGenerators[curVoice], mods);
			
			//voice.factor = 2;
			audioPlayers[curVoice].play(voice);
			audioPlayers[curVoice].preset = preset.name;
			
			if (curVoice < maxVoices - 1)
				curVoice++;
			else
				curVoice = 0;
		}
	}		
}