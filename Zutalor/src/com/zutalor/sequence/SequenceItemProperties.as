package com.zutalor.sequence  
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SequenceItemProperties extends PropertiesBase implements IProperties
	{
		public var item:String;
		public var delay:Number;
	}
}