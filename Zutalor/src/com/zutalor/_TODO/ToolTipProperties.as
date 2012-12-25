package com.zutalor.properties  
{
	import com.zutalor.interfaces.IProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ToolTipProperties extends PropertiesBase implements IProperties
	{		
		public var width:Number;
		public var height:Number;
		public var textAttributes:String;
		public var fadeTime:Number;
		public var delay:Number;
		public var backgroundpresetId:String;
		public var hPadText:int;
		public var vPadText:int;
		public var hPadBackground:int;
		public var vPadBackground:int;
	}
}