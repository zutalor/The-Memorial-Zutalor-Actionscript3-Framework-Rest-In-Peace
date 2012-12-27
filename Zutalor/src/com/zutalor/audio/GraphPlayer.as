package com.zutalor.audio
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.zutalor.loaders.URLLoaderG;
	import com.zutalor.synthesizer.properties.Note;
	import com.zutalor.synthesizer.properties.Track;
	import com.zutalor.synthesizer.Synthesizer;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.ArrayUtils;
	import com.zutalor.utils.MathG;
	import com.zutalor.widgets.Spinner;
	
	public class GraphPlayer
	{
		public var functionNames:Array = ["linear", "exponential", "logistic", "sine wave", "sine + logistic", "linear + noise", "random"];
		public var functions:Array = [ calcLinear, calcExp, calcLogistic1, calcSin ];
		
		public static const MAX_GRAPHS:int = 3;
		public var synthesizer:Synthesizer;
		public var xmlUrl:String;
		public var assetPath:String;
		public var data:Vector.<Array>;

		public var expScaling:Number = 0.0303;
		public var linearScaling:int = 2;
		public var samples:int = 100;
		public var freq:Number = 11;
		public var sinShift:int = 200;
		public var amp:Number = 50;
		public var logisticScaling:Number = .18;
		
		private var _intitialized:Boolean;
		private var _isPlaying:Boolean;
		private var _curData:Array;
		private var _onComplete:Function;
		private var _numTracks:int;
		
		public function initialize(p:String = null, onComplete:Function = null):void
		{
			var params:Array;
			var gs:GraphSettings;				

			if (!_intitialized)
			{	
				_onComplete = onComplete;
				_intitialized = true;				
				params = p.split(",");
				xmlUrl = TextUtil.strip(params[0]);
				assetPath = TextUtil.strip(params[1]);
				synthesizer = new Synthesizer(AudioDescriptor.RATE_44100, 8192, MAX_GRAPHS);			
				synthesizer.sounds.load(xmlUrl, assetPath, onComplete); 
				prepareData();	
			}
		}
				
		public function stop():void
		{
			if (synthesizer)
				synthesizer.sequencer.stop();
			
			_isPlaying = false;
		}
						
		public function play(graphCollection:Array, onComplete:Function):void
		{
			var gs:GraphSettings;
			var max:Array;
			var curMax:Number;
			var maxIndx:int;
			var temp:Array;
			var note:Note;

			_onComplete = onComplete;
			synthesizer.sequencer.stop();
			max = [];
			_curData = [];
			_isPlaying = true;
			
			_numTracks = graphCollection.length;
			for (var i:int = 0; i < _numTracks; i++)
			{
				gs = graphCollection[i];
				gs.noteScaling = 1;
				//gs.preset = makeSynthPreset(gs);
				_curData[i] = data[ gs.graph ]; 							
				max[i] = ArrayUtils.getMax(_curData[i]);
				if (max[i] > curMax)
				{
					curMax = max[i];
					maxIndx = i;
				}	
			}
			
			// adjust audio data to scale properly in relation to graph data.
		
			for (i = 0; i < _numTracks; i++)
			{
				if (maxIndx != i)
				{
					if (curMax > max[i])
						gs[i].noteScaling = max[i] / curMax;
				}
			}
			
			// now render graphs and play
			var t:Track;
			
			for (i = 0; i < _numTracks; i++)
			{
				gs = graphCollection[i];
				t = synthesizer.tracks.getByIndex(i);
				temp = ArrayUtils.compress(_curData[i], 0, ArrayUtils.getMax(data[i]), gs.preset.lowNote, gs.preset.highNote, gs.noteScaling);
				
				for (var x:int = 0; x < temp.length; x++)
				{
					t.notes[x] = new Note();
					note = t.notes[x];
					note.note = temp[x];
					note.attack = gs.preset.attack;
					note.decay = gs.preset.decay;
					note.sustain = gs.preset.sustain;
					note.release = gs.preset.release;
					note.hold = gs.preset.hold;
					note.startTime = gs.preset.noteTiming * x;
				}
				t.preset = gs.preset;
				t.mute = gs.mute;
			}
			synthesizer.sequencer.renderTracks(_numTracks);
			synthesizer.sequencer.play(playbackComplete);
			
			function playbackComplete():void
			{
				if (_isPlaying)
				{
					stop();
					synthesizer.sequencer.reset();
				}	
				_onComplete();
			}		
		}
						
		
		
		private function prepareData():void
		{
			var tmp:Array = [];
			
			data = new Vector.<Array>(functions.length+3);
			for (var i:int = 0; i < functions.length; i++)
			{
				data[i] = [];
				calculate(data[i], samples, functions[i]);
			}
			
			i = data.length - 3;
			data[i] = [];
			calculate(data[i], samples, calcLogistic1);
			calculate(tmp, samples, calcSin);
			data[i] = ArrayUtils.mix(data[i], tmp, .7, .5);
			
			i++;
			data[i] = [];
			calculate(data[i], samples, calcLinear);
			ArrayUtils.addNoise(data[i], -20, 20, 1, 1, 1);
			
			i++;
			data[i] = [];
			calculate(data[i], samples, calcRandom)
		}

		// PLOTTING FUNCTIONS
		
		private function calculate(a:Array, samples:int, plottingFunction:Function):void
		{
			var x:Number;
			
			
			for (var i:int; i < samples; i++)
			{
				x = i * 200 / samples;
				a[i] = plottingFunction(x);
			}
		}				
		
		private function calcRandom(x:Number):Number
		{
			return MathG.rand(100, 200);
		}
		
		private function calcLogistic1(x:Number):Number
		{
			x = (x - (samples / 1)) * logisticScaling;
			return (1 / (1 + Math.exp((x/3) * -1))) * 400;
		}
		

		private function calcExp(x:uint):Number
		{
			return Math.exp(x * expScaling);
		}
		
		private function calcLog(x:uint):Number
		{
			return Math.log(x) * 90;
		}

		private function calcLinear(x:uint):Number
		{
			return x * linearScaling;
		}
		
		private function calcSin(x:uint):Number
		{	
			return (Math.sin(Math.PI / 180 * x * freq) * amp) + sinShift;
		}
		
		private function calcSin2(x:uint):Number
		{	
			return (Math.sin(Math.PI / 180 * x * freq) * amp);
		}
				
		private function calcSinExp(x:uint):Number
		{
			return Math.sin(Math.PI / 180 * x * 500) * 10 + Math.exp(x * expScaling);
		}
	}
}