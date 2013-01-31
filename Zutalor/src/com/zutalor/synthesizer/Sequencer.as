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
		private var egs:int;
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
			var nextTrigger:Number;
			var note:Number;
			var v:IAudioSource;
			var bm:BendModulation;
			var l:int;
			var i:int;
			var offset:Number;
			var offsetIndx:int;
			var preset:SynthPreset;
									
			if (!tracksToRender)
				numTracks = tracks.length;
			else
				numTracks = tracksToRender;
			
			envelopeGenerators = new Vector.<ADSREnvelopeGenerator>;
			egs = 0;
			listPerformance = new ListPerformance();
			trace("render");
			
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
						offset = track.notes[offsetIndx].midiNote;
						
						for (i = 0; i < l - 1; i++)
						{
							mods.push(new BendModulation(track.notes[i].startTime, track.notes[i].midiNote - offset, 
															nextTrigger, track.notes[i + 1].midiNote - offset));
															
							nextTrigger += preset.noteTiming;
							trace(nextTrigger);
						}
															
						envelopeGenerators[egs] = new ADSREnvelopeGenerator(monoAd, preset.attack, preset.decay, 
															track.notes.length * preset.noteTiming, preset.sustain, preset.release);							
						
						listPerformance.addSourceAt(0, sounds.getVoice(preset, track.notes[offsetIndx].midiNote, envelopeGenerators[egs],  mods));
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
							if (!preset.isAudioFrequencey)
								note = track.notes[i].midiNote;
							else
								note = AudioUtils.frequencyToNoteNumber(track.notes[i].midiNote);

							if (preset.rounding)
								note = Math.round(note);
	
								
							var s:IAudioSource = sounds.getVoice(preset, note, envelopeGenerators[egs - 1] , null)	
							listPerformance.addSourceAt(track.notes[i].startTime, s);
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
				
				//onSoundComplete(new Event(""));
//				audioPerformer.getSample(4096);
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
				for (i = 0; i < egs; i++)
				{
					envelopeGenerators[i].destroy();
					envelopeGenerators[i] = null;
				}
				
				audioPerformer.destroy();
				audioPerformer = null;
				envelopeGenerators = null;
				listPerformance = null;			
				egs = 0;
			}
		}
	}	
}