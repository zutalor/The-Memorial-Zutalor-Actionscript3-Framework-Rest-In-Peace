package com.zutalor.synthesizer
{
	import com.zutalor.utils.gDictionary;
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.filters.ResamplingFilter;
	import com.noteflight.standingwave3.generators.ADSREnvelopeGenerator;
	import com.noteflight.standingwave3.modulation.BendModulation;
	import com.noteflight.standingwave3.output.AudioPlayer;
	import com.noteflight.standingwave3.utils.AudioUtils;
	
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
		
		private var _audioPlayers:Vector.<AudioPlayer>;
		private var _envelopeGenerators:Vector.<ADSREnvelopeGenerator>;
		private var _curVoice:int;
		private var _framesPerCallBack:int;
		private var _sampleRate:int;
		private var _monoAD:AudioDescriptor;
		private var _stereoAD:AudioDescriptor;
		private var _maxVoices:int;
			
		public function Synthesizer(sampleRate:Number, framesPerCallBack:int, maxVoices:int = 16)
		{
			_framesPerCallBack = framesPerCallBack;
			_sampleRate = sampleRate;
			_maxVoices = maxVoices;
			_init();
		}	
		
		private function _init():void
		{
			voices = new Voices(_sampleRate);
			presets = new SynthPresets();
			tracks = new gDictionary();
			sequencer = new Sequencer(voices, presets, tracks, _framesPerCallBack, _sampleRate);
			_monoAD = new AudioDescriptor(_sampleRate, 1);
			_stereoAD = new AudioDescriptor(_sampleRate, 2);
			_audioPlayers = new Vector.<AudioPlayer>;
			_envelopeGenerators = new Vector.<ADSREnvelopeGenerator>(_maxVoices);
			for (var i:int = 0; i < _maxVoices; i++)
				_audioPlayers[i] = new AudioPlayer(_framesPerCallBack);
		}
		
		public function playNote(note:Number, preset:SynthPreset):void
		{
			var bm:BendModulation;
			var voice:ResamplingFilter;	

			if (preset.bendEndTime)
				bm = new BendModulation(preset.bendStartTime, preset.bendStartValue, preset.bendEndTime, preset.bendEndValue);	
			
			if (!preset.midiNoteNumbers)
				note = AudioUtils.frequencyToNoteNumber(note);

			if (preset.rounding)
				note = Math.round(note);
		
			if (_envelopeGenerators[_curVoice])	
			{
				_envelopeGenerators[_curVoice].destroy();
			}	
			if (preset.monophonic)
				for (var i:int = 0; i < _curVoice; i++)
					if (preset.name && _audioPlayers[i].preset == preset.name)
						_audioPlayers[i].stop();
			
			_envelopeGenerators[_curVoice] = new ADSREnvelopeGenerator(_monoAD, preset.attack, preset.decay, preset.hold, preset.sustain, preset.release);	
			voice = voices.getVoice(preset, note, _envelopeGenerators[_curVoice], [ bm ]);
			
			//voice.factor = 2;
			_audioPlayers[_curVoice].play(voice);
			_audioPlayers[_curVoice].preset = preset.name;
			
			if (_curVoice < _maxVoices - 1)
				_curVoice++;
			else
				_curVoice = 0;
		}
	}		
}