package com.zutalor.color 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ColorThemeItemProperties extends PropertiesBase implements IProperties
	{		
		public var hue:Number;
		public var saturation:Number;
		public var luminance:Number;
	}
}