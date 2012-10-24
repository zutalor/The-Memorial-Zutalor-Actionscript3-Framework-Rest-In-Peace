package com.zutalor.synthesizer 
{
	import com.noteflight.standingwave3.generators.ADSREnvelopeGenerator;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Track 
	{
		public var trackName:String;
		public var preset:SynthPreset;
		public var notes:Vector.<Note>;
		public var offset:Number;
		public var mute:Boolean;

		public function Track() 
		{
			notes = new Vector.<Note>;
		}
	}
}