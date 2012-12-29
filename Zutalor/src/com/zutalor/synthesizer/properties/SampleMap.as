package com.zutalor.synthesizer.properties
{
	import com.noteflight.standingwave3.sources.SamplerSource;
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SampleMap extends PropertiesBase implements IProperties
	{
		public var filebase:String;
		public var fileExt:String;
		public var baseMidiNote:int;
		public var interval:int;
		public var samples:int;
		public var loopStart:Number;
		public var loopEnd:Number;
		public var urls:Vector.<String>;
		public var samplerSources:Vector.<SamplerSource>;
		public var frequencies:Vector.<Number>;
	}	
}