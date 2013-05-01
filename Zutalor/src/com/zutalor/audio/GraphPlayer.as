package com.zutalor.audio
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.zutalor.synthesizer.properties.Note;
	import com.zutalor.synthesizer.properties.Track;
	import com.zutalor.synthesizer.Synthesizer;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.ArrayUtils;
	import com.zutalor.utils.MathG;
	
	public class GraphPlayer
	{
		public var isPlaying:Boolean;
		
		public var synthesizer:Synthesizer;
		public var xmlUrl:String;
		public var assetPath:String;
		public var data:Vector.<Array>;
	
		public var variableTiming:Boolean = true;
		public var variablePitch:Boolean = true;
				
		private var _intitialized:Boolean;

		public var  curGraphData:Array;
		private var _onComplete:Function;
		private var _numTracks:int;
		private var graphingFunctions:Array;
		
		public function GraphPlayer() { }
		
		public function initialize(xmlUrl:String, assetPath:String, pGraphingFunctions:Array, pMaxGraphs:int, pOnComplete:Function = null):void
		{
			var gs:GraphSettings;

			if (!_intitialized)
			{
				_intitialized = true;
				graphingFunctions = pGraphingFunctions;
				_onComplete = pOnComplete;

				this.xmlUrl = xmlUrl;
				this.assetPath = assetPath;
				synthesizer = new Synthesizer(AudioDescriptor.RATE_44100, 4096, 3);
				synthesizer.sounds.load(xmlUrl, assetPath, pOnComplete);
			}
		}
		
		public function pause():void
		{
			if (synthesizer)
				synthesizer.sequencer.pause();
		}
				
		public function stop():void
		{
			if (synthesizer)
				synthesizer.sequencer.stop();
			
			isPlaying = false;
			_onComplete = null;
		}
						
		public function play(graphCollection:Array, samples:int, onComplete:Function = null, onCompleteArgs:* = null):void
		{
			var gs:GraphSettings;
			var max:Array;
			var curMax:Number = 0;
			var maxIndx:int;
			var temp:Array;
			var note:Note;
			var t:Track;
			var maxValue:Number;

			_onComplete = onComplete;
			_numTracks = graphCollection.length;
			prepareData(samples);
			
			synthesizer.sequencer.stop();
			max = [];
			curGraphData = [];
			isPlaying = true;
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
					temp = ArrayUtils.compress(curGraphData[i], 0, ArrayUtils.getMax(curGraphData[i]), gs.preset.lowNote, gs.preset.highNote, gs.noteScaling);
					t.preset = gs.preset;
					t.mute = gs.preset.mute;
					makeNotes();
				}
			}
			
			function playbackComplete():void
			{
				isPlaying = false;
				if (_onComplete != null)
				{
					if (onCompleteArgs)
						_onComplete(onCompleteArgs);
					else
						_onComplete();
				}
			}
				
			function makeNotes():void
			{
				var startTime:Number = 0;
				var startTimes:Array;
				var maxTime:Number;
				var nextIncr:Number;
				var lastIncr:Number;
				var distance:Number;
				
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
					
					startTimes[x] = Math.abs(startTime);
					
					if (variableTiming)
					{
						if (x < temp.length)
						{
							distance = 1 - Math.abs((temp[x + 1]) - temp[x]);
							nextIncr =  distance * 5;

							if (! isNaN(nextIncr))
							{
								startTime += nextIncr;
								lastIncr = startTime;
							}
							else
								startTime += lastIncr;
						}
					}
					else
						startTime = gs.preset.noteTiming * x;
				}
				
				maxTime = ArrayUtils.getMax(startTimes);
				
				startTimes = ArrayUtils.linearConversion(startTimes, 0, maxTime, 0, gs.totalTime);
				
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