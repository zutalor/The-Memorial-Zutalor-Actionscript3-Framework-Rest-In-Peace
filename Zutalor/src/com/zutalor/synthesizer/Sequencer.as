package com.zutalor.synthesizer
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.generators.ADSREnvelopeGenerator;
	import com.noteflight.standingwave3.modulation.BendModulation;
	import com.noteflight.standingwave3.output.AudioPlayer;
	import com.noteflight.standingwave3.performance.AudioPerformer;
	import com.noteflight.standingwave3.performance.ListPerformance;
	import com.noteflight.standingwave3.utils.AudioUtils;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.utils.gDictionary;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Sequencer
	{	
		private var presets:PropertyManager;
		private var voices:Voices;
		private var envelopeGenerators:Vector.<ADSREnvelopeGenerator>;
		private var egs:int;
		private var listPerformance:ListPerformance;
		private var audioPerformer:AudioPerformer;
		private var player:AudioPlayer;
		private var tracks:gDictionary;
		private var stereoAd:AudioDescriptor;
		private var monoAd:AudioDescriptor;
		private var framesPerCallBack:int;
		private var onComplete:Function;
		private var onCompleteArgs:*;
		
		public function Sequencer(pVoices:Voices, pPresets:PropertyManager, pTracks:gDictionary, pFramesPerCallback:int, pSampleRate:Number)
		{
			init(pSampleRate);
			voices = pVoices;
			presets = pPresets;
			tracks = pTracks;
			framesPerCallBack = pFramesPerCallback;
		}
		
		private function init(sampleRate:Number):void
		{
			stereoAd = new AudioDescriptor(sampleRate, AudioDescriptor.CHANNELS_STEREO);
			monoAd = new AudioDescriptor(sampleRate, AudioDescriptor.CHANNELS_MONO);
			listPerformance = new ListPerformance();			
		}
				
		public function addTrack(track:Track):void
		{			
			tracks.insert(track.trackName, track);
		}
		
		public function getTrackByName(trackName:String):Track
		{
			return tracks.getByKey(trackName);
		}
		
		public function getTrackByIndex(index:int):Track
		{
			return tracks.getByIndex(index);
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
				numTracks = tracks.length;
			else
				numTracks = n;
			
			envelopeGenerators = new Vector.<ADSREnvelopeGenerator>;
			egs = 0;
			
			for (var t:int = 0; t < numTracks; t++)
			{					
				track = tracks.getByIndex(t);
				
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

						envelopeGenerators[egs] = new ADSREnvelopeGenerator(monoAd, preset.attack, preset.decay, track.notes.length * preset.noteTiming, preset.sustain, preset.release);							
						listPerformance.addSourceAt(0, voices.getVoice(preset, track.notes[offsetIndx].note, envelopeGenerators[egs],  mods));
						egs++;
					}
					else
					{
						if (preset.bendEndTime)
							bm = new BendModulation(preset.bendStartTime, preset.bendStartValue, preset.bendEndTime, preset.bendEndValue);	
					
						if (!preset.eachVoiceHasEg)
						{
							envelopeGenerators[egs] = new ADSREnvelopeGenerator(monoAd, preset.attack, preset.decay, preset.hold, preset.sustain, preset.release);	
							egs++;
						}
						for (i = 0; i < track.notes.length; i++)
						{
							if (preset.eachVoiceHasEg)
							{
								envelopeGenerators[egs] = new ADSREnvelopeGenerator(monoAd, preset.attack, preset.decay, preset.hold, preset.sustain, preset.release);	
							}
							if (preset.midiNoteNumbers)
								note = track.notes[i].note;
							else
								note = AudioUtils.frequencyToNoteNumber(track.notes[i].note);

							if (preset.rounding)
								note = Math.round(note);

								
							listPerformance.addSourceAt(track.notes[i].startTime, voices.getVoice(preset, note, envelopeGenerators[egs - 1] , null));

						}
					}
				}
			}
		}
				
		public function reset():void
		{
			var i:int;
			
			for (i = 0; i < listPerformance.elements.length; i++)
				listPerformance.elements[i] = null;
				
			listPerformance = new ListPerformance();
			for (i = 0; i < egs; i++)
			{
				envelopeGenerators[i].destroy();
				envelopeGenerators[i] = null;
			}
			envelopeGenerators = new Vector.<ADSREnvelopeGenerator>;
			
			egs = 0;
		}
		
		public function stop():void
		{
			if (player)
				player.stop();
		}
		
		public function pause():void
		{
			if (player)
				player.pause();
		}
		
		public function resume():void
		{
			if (player)
				player.resume();
		}
		
		public function play(pOnComplete:Function = null, pOnCompleteArgs:* = null):void // plays the current list performance.
		{	
			onComplete = pOnComplete;
			onCompleteArgs = pOnCompleteArgs;
			
			if (listPerformance && listPerformance.elements)		
			{
				audioPerformer = new AudioPerformer(listPerformance, stereoAd);
				audioPerformer.mixGain = tracks.length * -5;

				player = new AudioPlayer(framesPerCallBack);
				player.play(audioPerformer);
				player.addEventListener(Event.SOUND_COMPLETE, onSoundComplete, false, 0, true);
			}
		}		

		private function onSoundComplete(e:Event):void
		{
			reset();
			player.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			player = null;
			if (onComplete != null)
				if (onCompleteArgs != null)
					onComplete(onCompleteArgs);
				else
					onComplete();
		}
	}	
}