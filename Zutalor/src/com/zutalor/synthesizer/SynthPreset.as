package com.zutalor.synthesizer  
{
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SynthPreset
	{
		public var name:String;
		public var soundName:String;
		public var midiNoteNumbers:Boolean;
		public var rounding:Boolean;
		public var lowNote:Number;
		public var highNote:Number;
		public var noteTiming:Number;
		public var pan:Number;
		public var gain:Number;
		
		public var eachVoiceHasEg:Boolean;
		public var monophonic:Boolean;
		public var attack:Number;
		public var decay:Number;
		public var hold:Number;
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
		public var pvUp:Number 			// pitch variation
		public var pvDown:Number
		public var pvIterations:Number
		public var pvProbability:Number
		public var pvFalloff:Number		
		public var tvUp:Number 			// timing variation
		public var tvDown:Number
		public var tvIterations:Number
		public var tvProbability:Number
		public var tvFalloff:Number				
		
		public function SynthPreset() 
		{
		}
	}
}