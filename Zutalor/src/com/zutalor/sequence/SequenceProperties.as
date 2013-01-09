package com.zutalor.sequence  
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SequenceProperties extends PropertiesBase implements IProperties
	{
		public function SequenceProperties() { }
		
		public var loop:Boolean;
	}
}