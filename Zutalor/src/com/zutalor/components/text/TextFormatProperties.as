package com.zutalor.components.text
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.utils.MapXML;
	import com.zutalor.utils.Resources;
	import flash.text.Font;
	import flash.text.TextFormat;
	
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
		public var textFormat:TextFormat;
		
		override public function parseXML(xml:XML):Boolean
		{	
			MapXML.attributesToClass(xml , this); // map the properties
			name = name.toLowerCase();
			textFormat = makeTextFormat();
			return true;
		}
		
		private function makeTextFormat():TextFormat
		{
			var tf:TextFormat;
			
			tf = new TextFormat();
			tf.align = align;
			tf.blockIndent = blockIndent;
			tf.bold = bold;
			tf.color = color;
			if (font)
			{
				var klass:Class;
				var fontInstance:Font;
				
				klass = Resources.getClass(font);
				fontInstance = new klass();
				tf.font = fontInstance.fontName;
			}
			tf.indent = indent;
			tf.italic = italic;
			tf.kerning = kerning;
			tf.leading = leading;
			tf.leftMargin = leftMargin;
			tf.letterSpacing = letterSpacing;
			tf.rightMargin = rightMargin;
			tf.size = size;
			tf.underline = underline;
			return tf;
		}
	}
}