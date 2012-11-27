package com.zutalor.components.button 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ButtonProperties extends PropertiesBase implements IProperties
	{		
		public var upId:String;
		public var overId:String;
		public var downId:String;
		public var disabledId:String;
		
		//the following apply to the text fields
		
		public var textAttributes:String;
		public var textAttributesDown:String;
		public var textAttributesDisabled:String;
		
		public var width:int; 
		public var height:int;
		public var align:String;
		public var vPad:int;				
		public var hPad:int;				
	}
}