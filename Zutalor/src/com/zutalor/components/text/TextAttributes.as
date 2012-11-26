package com.zutalor.components.text 
{
	import com.zutalor.components.html.StyleSheets;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.ShowError;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff
	 */
	public class TextAttributes 
	{
		public static var _textAttributes:PropertyManager;
		public static var _textFormats:PropertyManager;
		
		public static function register(textAttributes:XMLList, textFormats:XMLList):void
		{	
			if (!_textAttributes)
			{
				_textAttributes = new PropertyManager(TextAttributeProperties);
				_textFormats = new PropertyManager(TextFormatProperties);
			}
			
			_textAttributes.parseXML(textAttributes);
			_textFormats.parseXML(textFormats);
		}
		
		public static function apply(t:TextField, attributesPreset:String, width:int = 0, height:int = 0, beginIndex:int = -1, endIndex:int = -1):void
		{			
			var tap:TextAttributeProperties;
			tap = _textAttributes.getPropsByName(attributesPreset);
			if (!tap)
				ShowError.fail(TextUtil,"Text attribute not found:" + attributesPreset);
			
			if (height)
				t.height = height;
			
			if (width)
				t.width = width;
			
			t.selectable = tap.selectable;
			
			t.type = tap.type;
			t.autoSize = tap.autoSize;
			t.antiAliasType = tap.antiAliasType;
			t.multiline = tap.multiline;
			t.wordWrap = tap.wordWrap;
			t.embedFonts = true;
			if (tap.maxChars)
				t.maxChars = tap.maxChars;
			
			if (tap.stylesheet)
				t.styleSheet = StyleSheets.getStyleSheetById(tap.stylesheet);
			else if (tap.textformat)
				t.setTextFormat(_textFormats.getPropsByName(tap.textformat).textFormat, beginIndex, endIndex);
			else
				ShowError.fail(TextUtil,"Missing textformat for textAttributes: " + tap.name);
		}
	}
}