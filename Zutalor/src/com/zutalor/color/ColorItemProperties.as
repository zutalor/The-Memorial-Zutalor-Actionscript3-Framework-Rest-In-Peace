package com.zutalor.color 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ColorItemProperties extends PropertiesBase implements IProperties
	{		
		public function ColorItemProperties() { }
		
		public var hue:Number;
		public var saturation:Number;
		public var luminance:Number;
	}
}