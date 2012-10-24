package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.MapXML;
	import flash.display.LineScaleMode;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ButtonProperties extends PropertiesBase implements IProperties
	{		
		public var upGid:String;
		public var overGid:String;
		public var downGid:String;
		public var selectedGid:String;
		public var disabledGid:String;
		public var textAttributes:String;
		public var textAttributesOver:String;
		public var textAttributesDown:String;
		public var textAttributesSelected:String;
		public var textAttributesDisabled:String;
		public var textAttributesHeading:String;
		public var width:int; //the following apply to the text fields
		public var height:int;
		public var align:String;
		public var vPad:int;				
		public var hPad:int;				
	}
}