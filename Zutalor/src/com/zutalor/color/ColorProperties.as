package com.zutalor.color 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ColorProperties extends PropertiesBase implements IProperties
	{		
		public function ColorProperties() { }
		
		public var basedOnTheme:String;
		public var basedOnItem:String;
		public var hueShift:Number;
		public var saturationShift:Number;
		public var luminanceShift:Number;
	}
}