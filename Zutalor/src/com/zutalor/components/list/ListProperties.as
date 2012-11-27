package com.zutalor.components.list 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ListProperties extends PropertiesBase implements IProperties
	{	
		public var selectorId:String;
		public var background:String;
		public var itemBackground:String;
		public var textAttributes:String;
		public var width:String;
		public var height:String;
		public var align:String;
		public var hPad:String;
		public var vPad:Number;
		public var spacing:Number;
	}
}