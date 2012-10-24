package com.zutalor.properties
{
	import com.zutalor.interfaces.IProperties;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TextFormatProperties extends PropertiesBase implements IProperties
	{
		public var align:String;
		public var blockIndent:int;
		public var bold:Boolean;
		public var color:String;
		public var font:String;
		public var indent:String;
		public var italic:Boolean;
		public var kerning:Boolean;
		public var leading:String;
		public var leftMargin:String;
		public var letterSpacing:String;
		public var rightMargin:String;
		public var size:String;
		public var underline:Boolean;
	}
}