package com.zutalor.synthesizer 
{
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.filters.PanFilter;
	import com.noteflight.standingwave3.sources.SamplerSource;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Voice 
	{
		public var noteNumber:Number;
		public var samplerSource:SamplerSource;
		public var factor:Number;
		public var freq:Number;	
		public var sound:PanFilter;
	}
}