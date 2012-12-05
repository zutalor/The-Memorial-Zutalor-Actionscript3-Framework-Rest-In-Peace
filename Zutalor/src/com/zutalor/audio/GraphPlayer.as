package com.zutalor.audio
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.zutalor.loaders.URLLoaderG;
	import com.zutalor.synthesizer.Note;
	import com.zutalor.synthesizer.Synthesizer;
	import com.zutalor.synthesizer.SynthPreset;
	import com.zutalor.synthesizer.Track;
	import com.zutalor.text.TextUtil;
	import com.zutalor.widgets.Plotter;
	import com.zutalor.widgets.Spinner;
	import com.zutalor.utils.ArrayUtils;
	import com.zutalor.utils.MathG;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	public class GraphPlayer extends Sprite
	{
		public var functionNames:Array = ["linear", "exponential", "logistic", "sine wave", "sine + logistic", "linear + noise", "random"];
		public var functions:Array = [ calcLinear, calcExp, calcLogistic1, calcSin ];
		
		public static const MAX_GRAPHS:int = 3;
		public static const TOUCH_TOLERANCE:int = 5;
		public static const VIBRATE_MS:int = 20;
		
		public var synthesizer:Synthesizer;
		
		public var xmlUrl:String;
		public var assetPath:String;
		public var graphCollection:Vector.<GraphSettings>;
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
		private var _lastPlayTime:uint;
		private var _lastNote:Number;
		private var _lastGraphPlayed:int;
		private var _chart:Sprite;
		private var _onComplete:Function;
		
		public function initialize(p:String = null, onComplete:Function = null):void
		{
			var params:Array;
			var gs:GraphSettings;				

			if (!_intitialized)
			{
				_onComplete = onComplete;
				Spinner.show();
				_intitialized = true;				
				
				graphCollection = new Vector.<GraphSettings>(MAX_GRAPHS);
				synthesizer = new Synthesizer(AudioDescriptor.RATE_44100, 8192);
				
				//if (AirStatus.isPortable)
				//	_vibration = new Vibration();

				params = p.split(",");
				x = int(params[0]);
				y = int(params[1]);
				width = int(params[2]);
				height = int(params[3]);
				xmlUrl = TextUtil.strip(params[4]);
				assetPath = TextUtil.strip(params[5]);
				initSynth(); 
				
				for (var i:int = 0; i < MAX_GRAPHS; i++)
				{
					graphCollection[i] = new GraphSettings();
					gs = graphCollection[i];
					gs.mute = false;
					gs.trackName = String(i);
					gs.graphType = i;
					gs.pan = i;
					gs.sound = 0;
					gs.soundName = "1";
					synthesizer.tracks.insert(String(i), new Track());
					gs.plotter = new Plotter(width-2, height);
					gs.plotter.x = x;
					gs.plotter.y = y;
					addChild(gs.plotter);
				}		
				prepareData();	
			}
		}
				
		public function stop():void
		{
			if (synthesizer)
				synthesizer.sequencer.stop();
			_isPlaying = false;
		}
						
		public function play(numTracks:int):void
		{
			var gs:GraphSettings;
			var max:Array;
			var curMax:Number;
			var maxIndx:int;
			var temp:Array;
			var note:Note;

			synthesizer.sequencer.stop();
			max = [];
			_curData = [];
			_isPlaying = true;
			for (var i:int = 0; i < numTracks; i++)
			{
				gs = graphCollection[i];
				gs.noteScaling = 1;
				gs.preset = makePreset(gs);
				gs.plotter.graphics.clear();
				gs.plotter.cancel();
				switch(i)
				{
					case 0 :
						gs.color = 0x4499FF;
						break;
					case 1 :
						gs.color = 0x8D6FCE;
						break;
					case 2 :
						gs.color = 0x78CDB6;
						break;	
					default :
						gs.color = 0x0080C0;
				}

				gs.plotter.graphics.lineStyle(1, gs.color);
				gs.plotter.dotSize = 2;
				
				_curData[i] = data[ functionNames.indexOf(gs.preset.metadata) ]; 							
				max[i] = ArrayUtils.getMax(_curData[i]);
				if (max[i] > curMax)
				{
					curMax = max[i];
					maxIndx = i;
				}	
			}
			
			// adjust audio data to scale properly in relation to other data.
		
			for (i = 0; i < numTracks; i++)
			{
				if (maxIndx != i)
				{
					if (curMax > max[i])
						gs[i].noteScaling = max[i] / curMax;
				}
			}
			
			// now render graphs and play
			var t:Track;
			
			for (i = 0; i < numTracks; i++)
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
			synthesizer.sequencer.renderTracks(numTracks);
			synthesizer.sequencer.play(playbackComplete);
		}
		
		private function playbackComplete():void
		{
			if (_isPlaying)
			{
				stop();
				synthesizer.sequencer.reset();

				//StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				
				for (var i:int = 0; i < MAX_GRAPHS; i++)
					if (!graphCollection[i].mute)
						graphCollection[i].plotter.draw(_curData[i], null, 0, samples, 2);
			}		
		}		
				
		private function makePreset(gs:GraphSettings):SynthPreset
		{
			var sp:SynthPreset = new SynthPreset();
			
			sp.name = gs.trackName;
			sp.soundName = gs.soundName;
			sp.midiNoteNumbers = true;
			sp.rounding = false;
			
			sp.lowNote = 30 + (gs.range * 40);
			sp.highNote = 52 + (gs.range * 40);
										
			sp.pan = gs.pan; 
			
			if (!sp.pan) // TODO: for some reason standingWave addsourceAt won't play if pan is 0, check to see if right and left are cancelling each other out.
					sp.pan = .2;
			
			sp.gain = -6;
			
			sp.noteTiming = gs.speed;
			
			if (!gs.noteOverlap)
			{
				sp.dataIsPitchBend = true;
				sp.loopStart = .6;
				sp.loopEnd = 2;
			}
			else
				sp.hold = gs.noteOverlap;
			
			sp.decay = .01;
			sp.release = .03;
			sp.attack = .25
			sp.sustain = 1;
			
			sp.metadata = functionNames[gs.graphType];
			return sp;
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
				
		private function initSynth():void
		{
			var xml:XML;
			var loader:URLLoaderG = new URLLoaderG();
			loader.load(xmlUrl, onXMLLoadComplete);
		
			function onXMLLoadComplete(lg:URLLoaderG):void
			{
				//TODO Handle error.
				xml = XML(lg.data);
				synthesizer.voices.load(xml, assetPath, finishSetup);
			}
					
			function finishSetup():void
			{
				synthesizer.presets.parseXml(xml);
				Spinner.hide();
				
				if (_onComplete != null)
					_onComplete();
			}
		}	
		
		private function onMouseMove(me:MouseEvent):void
		{
			soundOnMove(_chart.mouseX, _chart.mouseY);
		}
		
		private function soundOnMove(mouseX:int, mouseY:int):void
		{	
			var sp:SynthPreset;
			var gs:GraphSettings;
			
			var x:int;
			var y:int;
			var t:Track;
			var note:Number;
			
			if (!_lastPlayTime || (getTimer() - _lastPlayTime > 20)) 
			{
				for (var i:int = 0; i < MAX_GRAPHS; i++)
				{
					gs = graphCollection[i];
				
					if (!gs.mute)
					{
						// first find the index into the array which, with the offset, we'll get us the Y we're testing for.
						x = MathG.linearConversion(mouseX - gs.plotter.x, 0, width, 0, gs.plotter.displayData.length / 2);
						y = mouseY;
						x *= 2;
						
						if (!(x % 2))
							x++;

						if (Math.abs(y - gs.plotter.displayData[x] - gs.plotter.y ) < TOUCH_TOLERANCE)
						{
							t = synthesizer.tracks.getByIndex(i);
							var w:int = MathG.linearConversion(x, 0, gs.plotter.displayData.length, 0, t.notes.length);
							note = t.notes[w].note;
						
							_lastPlayTime = getTimer();
						
							sp = makePreset(gs);
							
							_lastNote = note;
							_lastGraphPlayed = i;

							sp.attack = .01;
							sp.hold = .2;
							sp.loopStart = .05;
							sp.loopEnd = .5;
							sp.release = .01;
							sp.monophonic = false;
							sp.name = String(i);

							synthesizer.playNote(note, sp );
								
							//if (AirStatus.isPortable)
							//	_vibration.vibrate(VIBRATE_MS);
						}
					}
				}
			}
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