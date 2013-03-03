package com.zutalor.audio
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.zutalor.synthesizer.properties.Note;
	import com.zutalor.synthesizer.properties.Track;
	import com.zutalor.synthesizer.Synthesizer;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.ArrayUtils;
	
	public class GraphPlayer
	{
		public var synthesizer:Synthesizer;
		public var xmlUrl:String;
		public var assetPath:String;
		private var data:Vector.<Array>;
	
		public var variableTiming:Boolean = true;
		public var variablePitch:Boolean = true;
		public var totalTime:Number = 10;
				
		private var _intitialized:Boolean;
		private var _isPlaying:Boolean;
		public var  curGraphData:Array;
		private var _onComplete:Function;
		private var _numTracks:int;
		private var graphingFunctions:Array;
		
		public function GraphPlayer() { }
		
		public function initialize(pParams:String, pGraphingFunctions:Array, pMaxGraphs:int, pOnComplete:Function = null):void
		{
			var params:Array;
			var gs:GraphSettings;

			if (!_intitialized)
			{
				_intitialized = true;
				graphingFunctions = pGraphingFunctions;
				_onComplete = pOnComplete;

				params = pParams.split(",");
				xmlUrl = TextUtil.strip(params[0]);
				assetPath = TextUtil.strip(params[1]);
				synthesizer = new Synthesizer(AudioDescriptor.RATE_44100, 8192, 3);
				synthesizer.sounds.load(xmlUrl, assetPath, pOnComplete);
			}
		}
				
		public function stop():void
		{
			if (synthesizer)
				synthesizer.sequencer.stop();
			
			_isPlaying = false;
		}
						
		public function play(graphCollection:Array, samples:int, onComplete:Function):void
		{
			var gs:GraphSettings;
			var max:Array;
			var curMax:Number;
			var maxIndx:int;
			var temp:Array;
			var note:Note;
			var t:Track;

			_onComplete = onComplete;
			_numTracks = graphCollection.length;
			prepareData(samples);
			
			synthesizer.sequencer.stop();
			max = [];
			curGraphData = [];
			_isPlaying = true;
			
			assignData();
			scaleAudioData();
			renderGraphs();
			
			synthesizer.sequencer.renderTracks(_numTracks);
			synthesizer.sequencer.play(playbackComplete);
			
			function assignData():void
			{
				for (var i:int = 0; i < _numTracks; i++)
				{
					gs = graphCollection[i];
					gs.noteScaling = 1;
					curGraphData[i] = data[ gs.graph ];
					max[i] = ArrayUtils.getMax(curGraphData[i]);
					if (max[i] > curMax)
					{
						curMax = max[i];
						maxIndx = i;
					}
				}
			}
			
			function scaleAudioData():void
			{
				for (var i:int = 0; i < _numTracks; i++)
				{
					if (maxIndx != i)
					{
						if (curMax > max[i])
						{
							gs = graphCollection[i];
							gs.noteScaling = max[i] / curMax;
						}
					}
				}
			}
			
			function renderGraphs():void
			{
				for (var i:int; i < _numTracks; i++)
				{
					gs = graphCollection[i];
					t = synthesizer.tracks.getByIndex(i);
					temp = ArrayUtils.compress(curGraphData[i], 0, ArrayUtils.getMax(data[i]), gs.preset.lowNote, gs.preset.highNote, gs.noteScaling);
					t.preset = gs.preset;
					t.mute = gs.preset.mute;
					makeNotes();
				}
			}
			
			function playbackComplete():void
			{
				_isPlaying = false;
				_onComplete();
			}
				
			function makeNotes():void
			{
				var startTime:Number = 0;
				var duration:Number;
				var startTimes:Array;
				var maxTime:Number;
				
				if (gs.reverse)
					temp.reverse();
				
				t.notes = new Vector.<Note>(temp.length);
				startTimes = [];
				for (var x:int = 0; x < temp.length; x++)
				{
					note = new Note();
					t.notes[x] = note;

					if (gs.preset.midiNoteConstant)
						note.midiNote = gs.preset.midiNoteConstant;
					else
						note.midiNote = temp[x];
					
					note.attack = gs.preset.attack;
					note.decay = gs.preset.decay;
					note.sustain = gs.preset.sustain;
					note.release = gs.preset.release;
					note.hold = gs.preset.hold;
					
					startTimes[x] = startTime;

					if (variableTiming)
					{
						if (x < temp.length)
							startTime +=  (1 -(Math.abs(temp[x] - temp[x + 1]))) / 20;
					}
					else
						startTime = gs.preset.noteTiming * x;
				}
				
				maxTime = ArrayUtils.getMax(startTimes);
				startTimes = ArrayUtils.linearConversion(startTimes, 0, maxTime, 0, totalTime);
				
				for (x = 0; x < startTimes.length; x++)
				{
					t.notes[x].startTime = startTimes[x];
				}
			}
		}
		
		private function prepareData(samples:int):void
		{
			var tmp:Array = [];
			
			data = new Vector.<Array>(graphingFunctions.length);
			for (var i:int = 0; i < graphingFunctions.length; i++)
			{
				data[i] = [];
				calculate(data[i], samples, graphingFunctions[i]);
			}
		}

		private function calculate(a:Array, samples:int, plottingFunction:Function):void
		{
			var x:Number;
			
			for (var i:int; i < samples; i++)
			{
				x = i * 200 / samples;
				a[i] = plottingFunction(x);
			}
		}
	}
}