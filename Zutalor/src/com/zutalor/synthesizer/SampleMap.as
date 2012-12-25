package com.zutalor.synthesizer
{
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
	}	
}