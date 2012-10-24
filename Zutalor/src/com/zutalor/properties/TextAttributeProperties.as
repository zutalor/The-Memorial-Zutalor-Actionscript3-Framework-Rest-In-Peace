﻿package com.zutalor.properties
{
	import com.zutalor.interfaces.IProperties;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TextAttributeProperties extends PropertiesBase implements IProperties
	{
		public var type:String;
		public var stylesheet:String;
		public var textformat:String;
		public var selectable:Boolean;
		public var autoSize:String;
		public var antiAliasType:String = "advanced";
		public var multiline:Boolean;
		public var wordWrap:Boolean;
		public var maxChars:int;
		public var displayAsPassword:Boolean;
	}
}