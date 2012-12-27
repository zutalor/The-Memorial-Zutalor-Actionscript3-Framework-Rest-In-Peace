package com.zutalor.synthesizer
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.filters.ResamplingFilter;
	import com.noteflight.standingwave3.generators.ADSREnvelopeGenerator;
	import com.noteflight.standingwave3.modulation.BendModulation;
	import com.noteflight.standingwave3.output.AudioPlayer;
	import com.noteflight.standingwave3.utils.AudioUtils;
	import com.zutalor.synthesizer.properties.SynthPreset;
	import com.zutalor.synthesizer.properties.Track;
	import com.zutalor.utils.gDictionary;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Synthesizer
	{
		public var sounds:Sounds;
		public var sequencer:Sequencer;
		public var tracks:gDictionary;
		
		protected var audioPlayers:Vector.<AudioPlayer>;
		protected var envelopeGenerators:Vector.<ADSREnvelopeGenerator>;
		protected var curVoice:int;
		protected var framesPerCallBack:int;
		protected var sampleRate:int;
		protected var monoAD:AudioDescriptor;
		protected var maxVoices:int;
		protected var numTracks:int;
			
		public function Synthesizer(pSampleRate:Number, pFramesPerCallBack:int, pNumTracks:int, pMaxVoices:int = 16)
		{
			framesPerCallBack = pFramesPerCallBack;
			sampleRate = pSampleRate;
			maxVoices = pMaxVoices;
			numTracks = pNumTracks;
			init();
		}	
		
		protected function init():void
		{
			sounds = new Sounds(sampleRate);
			tracks = new gDictionary();
			sequencer = new Sequencer(sounds, tracks, framesPerCallBack, sampleRate);
			monoAD = new AudioDescriptor(sampleRate, 1);
			audioPlayers = new Vector.<AudioPlayer>;
			envelopeGenerators = new Vector.<ADSREnvelopeGenerator>(maxVoices);
			for (var i:int = 0; i < maxVoices; i++)
				audioPlayers[i] = new AudioPlayer(framesPerCallBack);
				
			for (i = 0; i < numTracks; i++)
				tracks.insert(String(i), new Track());
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
			
			voice = sounds.getVoice(preset, note, envelopeGenerators[curVoice], mods);
			
			audioPlayers[curVoice].play(voice);
			audioPlayers[curVoice].preset = preset.name;
			
			if (curVoice < maxVoices - 1)
				curVoice++;
			else
				curVoice = 0;
		}
	}		
}