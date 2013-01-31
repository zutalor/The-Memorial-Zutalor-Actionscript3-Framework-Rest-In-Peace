package com.zutalor.synthesizer.properties  
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SynthPreset extends PropertiesBase implements IProperties
	{
		public var soundName:String;
		public var midiNoteConstant:Number;
		public var isAudioFrequencey:Boolean;
		public var rounding:Boolean;
		public var lowNote:Number;
		public var highNote:Number;
		public var noteTiming:Number;
		public var pan:Number = 0;
		public var gain:Number = 0;
		public var mute:Boolean;
		public var eachVoiceHasEg:Boolean;
		public var monophonic:Boolean;
		public var attack:Number;
		public var decay:Number;
		public var hold:Number;
		public var overlap:Number = 0;
		public var sustain:Number;
		public var release:Number;
		public var start:Number = 0;
		public var loopStart:Number = 0;
		public var loopEnd:Number = 0;
		public var dataIsPitchBend:Boolean;
		public var bendStartTime:Number = 0;
		public var bendEndTime:Number = 0;
		public var bendStartValue:Number = 0;
		public var bendEndValue:Number = 0;
		
		public var humanize:Boolean; 	// affects below
		public var pvUp:Number; 			// pitch variation
		public var pvDown:Number;
		public var pvIterations:Number;
		public var pvProbability:Number;
		public var pvFalloff:Number;		
		public var tvUp:Number; 			// timing variation
		public var tvDown:Number;
		public var tvIterations:Number;
		public var tvProbability:Number;
		public var tvFalloff:Number;
		
		public function SynthPreset() { }
	}
}