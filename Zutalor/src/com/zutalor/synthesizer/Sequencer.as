package com.zutalor.synthesizer
{
	import com.zutalor.utils.gDictionary;
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.filters.PanFilter;
	import com.noteflight.standingwave3.filters.StandardizeFilter;
	import com.noteflight.standingwave3.generators.ADSREnvelopeGenerator;
	import com.noteflight.standingwave3.modulation.BendModulation;
	import com.noteflight.standingwave3.output.AudioPlayer;
	import com.noteflight.standingwave3.performance.AudioPerformer;
	import com.noteflight.standingwave3.performance.ListPerformance;
	import com.noteflight.standingwave3.performance.PerformableAudioSource;
	import com.noteflight.standingwave3.sources.SineSource;
	import com.noteflight.standingwave3.utils.AudioUtils;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Sequencer
	{	
		private var _presets:SynthPresets;
		private var _voices:Voices;
		private var _envelopeGenerators:Vector.<ADSREnvelopeGenerator>;
		private var _egs:int;
		private var _listPerformance:ListPerformance;
		private var _audioPerformer:AudioPerformer;
		private var _player:AudioPlayer;
		private var _tracks:gDictionary;
		private var _stereoAd:AudioDescriptor;
		private var _monoAd:AudioDescriptor;
		private var _framesPerCallBack:int;
		private var _onComplete:Function;
		private var _onCompleteArgs:*;
		
		public function Sequencer(voices:Voices, presets:SynthPresets, tracks:gDictionary, framesPerCallback:int, sampleRate:Number)
		{
			_init(sampleRate);
			_voices = voices;
			_presets = presets;
			_tracks = tracks;
			_framesPerCallBack = framesPerCallback;

		}
		private function _init(sampleRate:Number):void
		{
			_stereoAd = new AudioDescriptor(sampleRate, AudioDescriptor.CHANNELS_STEREO);
			_monoAd = new AudioDescriptor(sampleRate, AudioDescriptor.CHANNELS_MONO);
			_listPerformance = new ListPerformance();			
		}
				
		public function addTrack(track:Track):void
		{			
			_tracks.addOrReplace(track.trackName, track);
		}
		
		public function getTrackByName(trackName:String):Track
		{
			return _tracks.getByName(trackName);
		}
		
		public function getTrackByIndex(index:int):Track
		{
			return _tracks.getByIndex(index);
		}

		public function renderTracks(n:int=0):void
		{
			var track:Track;
			var numTracks:int;
			var nextTrigger:Number;
			var note:Number;
			var v:IAudioSource;
			var bm:BendModulation;
			var mods:Array;
			var l:int;
			var i:int;
			var offset:Number;
			var offsetIndx:int;
			var preset:SynthPreset;
									
			if (!n)
				numTracks = _tracks.length;
			else
				numTracks = n;
			
			_envelopeGenerators = new Vector.<ADSREnvelopeGenerator>;
			_egs = 0;
			
			for (var t:int = 0; t < numTracks; t++)
			{					
				track = _tracks.getByIndex(t);
				
				if (!track.mute)
				{
					if (track.offset)
						nextTrigger = track.offset;
					else
						nextTrigger = 0;
					
					preset = track.preset;
					
					if (preset.dataIsPitchBend)
					{
						mods = [];
						l = track.notes.length - 1;
						
						offsetIndx = Math.floor(track.notes.length / 2);
						offset = track.notes[offsetIndx].note;
								
						for (i = 0; i < l; i++)
							mods.push(new BendModulation(track.notes[i].startTime, track.notes[i].note - offset, nextTrigger + preset.noteTiming, track.notes[i + 1].note - offset));

						_envelopeGenerators[_egs] = new ADSREnvelopeGenerator(_monoAd, preset.attack, preset.decay, track.notes.length * preset.noteTiming, preset.sustain, preset.release);							
						_listPerformance.addSourceAt(0, _voices.getVoice(preset, track.notes[offsetIndx].note, _envelopeGenerators[_egs],  mods));
						_egs++;
					}
					else
					{
						if (preset.bendEndTime)
							bm = new BendModulation(preset.bendStartTime, preset.bendStartValue, preset.bendEndTime, preset.bendEndValue);	
					
						if (!preset.eachVoiceHasEg)
						{
							_envelopeGenerators[_egs] = new ADSREnvelopeGenerator(_monoAd, preset.attack, preset.decay, preset.hold, preset.sustain, preset.release);	
							_egs++;
						}
						for (i = 0; i < track.notes.length; i++)
						{
							if (preset.eachVoiceHasEg)
							{
								_envelopeGenerators[_egs] = new ADSREnvelopeGenerator(_monoAd, preset.attack, preset.decay, preset.hold, preset.sustain, preset.release);	
							}
							if (preset.midiNoteNumbers)
								note = track.notes[i].note;
							else
								note = AudioUtils.frequencyToNoteNumber(track.notes[i].note);

							if (preset.rounding)
								note = Math.round(note);

								
							_listPerformance.addSourceAt(track.notes[i].startTime, _voices.getVoice(preset, note, _envelopeGenerators[_egs - 1] , [ bm ]));

						}
					}
				}
			}
		}
				
		public function reset():void
		{
			var i:int;
			
			for (i = 0; i < _listPerformance.elements.length; i++)
				_listPerformance.elements[i] = null;
				
			_listPerformance = new ListPerformance();
			for (i = 0; i < _egs; i++)
			{
				_envelopeGenerators[i].destroy();
				_envelopeGenerators[i] = null;
			}
			_envelopeGenerators = new Vector.<ADSREnvelopeGenerator>;
			
			_egs = 0;
		}
		
		public function stop():void
		{
			if (_player)
				_player.stop();
		}
		
		public function pause():void
		{
			if (_player)
				_player.pause();
		}
		
		public function resume():void
		{
			if (_player)
				_player.resume();
		}
		
		public function play(onComplete:Function = null, onCompleteArgs:* = null):void // plays the current list performance.
		{	
			_onComplete = onComplete;
			_onCompleteArgs = onCompleteArgs;
			
			if (_listPerformance && _listPerformance.elements)		
			{
				_audioPerformer = new AudioPerformer(_listPerformance, _stereoAd);
				_audioPerformer.mixGain = _tracks.length * -5;

				_player = new AudioPlayer(_framesPerCallBack);
				_player.play(_audioPerformer);
				_player.addEventListener(Event.SOUND_COMPLETE, onSoundComplete, false, 0, true);
			}
		}		

		private function onSoundComplete(e:Event):void
		{
			reset();
			_player.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_player = null;
			if (_onComplete != null)
				if (_onCompleteArgs != null)
					_onComplete(_onCompleteArgs);
				else
					_onComplete();
		}
	}	
}