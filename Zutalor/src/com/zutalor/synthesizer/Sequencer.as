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
	import com.zutalor.synthesizer.properties.SynthPreset;
	import com.zutalor.synthesizer.properties.Track;
	import com.zutalor.utils.gDictionary;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Sequencer
	{	
		private var sounds:Sounds;
		private var envelopeGenerators:Vector.<ADSREnvelopeGenerator>;
		private var listPerformance:ListPerformance;
		private var audioPerformer:AudioPerformer;
		private var player:AudioPlayer;
		private var tracks:gDictionary;
		private var stereoAd:AudioDescriptor;
		private var monoAd:AudioDescriptor;
		private var framesPerCallBack:int;
		private var mods:Array;		
		private var onComplete:Function;
		private var onCompleteArgs:*;
		
		public function Sequencer(pSounds:Sounds, pTracks:gDictionary, pFramesPerCallback:int, pSampleRate:Number)
		{
			init(pSampleRate);
			sounds = pSounds;
			tracks = pTracks;
			framesPerCallBack = pFramesPerCallback;
		}
		
		private function init(sampleRate:Number):void
		{
			stereoAd = new AudioDescriptor(sampleRate, AudioDescriptor.CHANNELS_STEREO);
			monoAd = new AudioDescriptor(sampleRate, AudioDescriptor.CHANNELS_MONO);
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

		public function renderTracks(tracksToRender:int=0):void
		{
			var track:Track;
			var numTracks:int;
			var midiNote:Number;
			var v:IAudioSource;
			var bm:BendModulation;
			var l:int;
			var i:int;
			var pitchOffset:Number;
			var pitchOffsetIndx:int;
			var preset:SynthPreset;
			var eg:ADSREnvelopeGenerator;
									
			if (!tracksToRender)
				numTracks = tracks.length;
			else
				numTracks = tracksToRender;
			
			envelopeGenerators = new Vector.<ADSREnvelopeGenerator>;
			listPerformance = new ListPerformance();
			trace("render");
			
			for (var t:int = 0; t < numTracks; t++)
			{					
				track = tracks.getByIndex(t);
				
				if (!track.mute)
				{
					if (!track.offset)
						track.offset = 0;
					
					preset = track.preset;
					
					if (preset.dataIsPitchBend)
					{
						mods = [];	
						l = track.notes.length - 1;
						pitchOffsetIndx = l / 2;
						pitchOffset = track.notes[pitchOffsetIndx].midiNote;
						
						for (i = 0; i < l - 1; i++)
						{
							mods.push(new BendModulation(track.notes[i].startTime, track.notes[i].midiNote - pitchOffset, 
															track.notes[i+1].startTime, track.notes[i + 1].midiNote - pitchOffset));
															
						}
															
						eg = new ADSREnvelopeGenerator(monoAd, preset.attack, preset.decay, 
															track.notes[l].startTime, preset.sustain, preset.release);
						
						listPerformance.addSourceAt(track.offset, sounds.getVoice(preset, track.notes[pitchOffsetIndx].midiNote, eg,  mods));
					}
					else
					{
						if (preset.bendEndTime)
							bm = new BendModulation(preset.bendStartTime, preset.bendStartValue, preset.bendEndTime, preset.bendEndValue);	
					
						if (!preset.eachVoiceHasEg)
							eg = new ADSREnvelopeGenerator(monoAd, preset.attack, preset.decay, preset.hold, preset.sustain, preset.release);	

						for (i = 0; i < track.notes.length - 1; i++)
						{
							if (preset.eachVoiceHasEg)
							{
								eg = new ADSREnvelopeGenerator(monoAd, preset.attack, preset.decay, 
																		(track.notes[i + 1].startTime - track.notes[i].startTime) * preset.overlap,
																		preset.sustain, preset.release);
								envelopeGenerators.push(eg);
								trace(track.notes[i + 1].startTime - track.notes[i].startTime )
							}
							if (!preset.isAudioFrequencey)
								midiNote = track.notes[i].midiNote;
							else
								midiNote = AudioUtils.frequencyToNoteNumber(track.notes[i].midiNote);

							if (preset.rounding)
								midiNote = Math.round(midiNote);
								
							var s:IAudioSource = sounds.getVoice(preset, midiNote, eg , null)	
							listPerformance.addSourceAt(track.notes[i].startTime + track.offset, s);
						}
					}
				}
			}
		}
		
		public function stop():void
		{
			if (player)
			{
				player.stop();
				reset();
			}
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
				if (tracks.length > 1)
					audioPerformer.mixGain = tracks.length * -2;
			
				if (!player)
					player = new AudioPlayer(framesPerCallBack);
				
				player.addEventListener(Event.SOUND_COMPLETE, onSoundComplete, false, 0, true);
				player.play(audioPerformer);	
			}
		}	
			
		private function onSoundComplete(e:Event):void
		{
			reset();
			trace("complete");
			player.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			if (onComplete != null)
				if (onCompleteArgs != null)
					onComplete(onCompleteArgs);
				else
					onComplete();			
		}

		private function reset():void
		{
			var i:int;
				
			if (listPerformance)
			{
				trace("reset");
				for (i = 0; i < envelopeGenerators.length; i++)
				{
					envelopeGenerators[i].destroy();
					envelopeGenerators[i] = null;
				}
				
				audioPerformer.destroy();
				audioPerformer = null;
				envelopeGenerators = null;
				listPerformance = null;			
			}
		}
	}	
}