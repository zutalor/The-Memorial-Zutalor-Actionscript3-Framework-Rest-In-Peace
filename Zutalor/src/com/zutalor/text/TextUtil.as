package com.zutalor.text
{
	import com.zutalor.properties.TextFormatProperties;
	import com.zutalor.propertyManagers.Presets
	import com.zutalor.properties.TextAttributeProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.DisplayUtils;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.Resources;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filters.GradientGlowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 * TODO: error checking.
	 */
	public class TextUtil
	{
		public static var textFormats:gDictionary;
		
		private static var _txt:TextField;
		private static var _width:int;
		private static var _stylesheet:String;
		private static var _onComplete:Function;
		private static var _unique:int;
		
		public static var css:StyleSheet;
		
		public static function load(url:String, onComplete:Function, textField:TextField = null, width:int = 0, stylesheet:String = null):void
		{
			var urlLoader:URLLoader = new URLLoader();
			var urlRequest:URLRequest;
			
			_onComplete = onComplete;
			_width = width;
			
			_txt = textField;
			_stylesheet = stylesheet;
			
			urlLoader = new URLLoader();
			urlRequest = new URLRequest(url);
			urlLoader.load(urlRequest);
			urlLoader.addEventListener(Event.COMPLETE, _onTextLoadComplete, false, 0, true);
		}
		
		private static function _onTextLoadComplete(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, _onTextLoadComplete);
			event.target.close();
			if (_txt)
			{
				if (_stylesheet)
					applyStylesheet(_txt, _stylesheet, _width);
				
				_txt.htmlText = event.target.data;
				_txt.height = _txt.textHeight;
				smoothHtmlBitmaps(_txt);
			}
			if (_onComplete != null)
				_onComplete();
		}
		
		public static function applyStylesheet(textField:TextField, stylesheet:String, width:Number = 0):void
		{
			textField.styleSheet = StyleSheetUtils.getStyleSheetById(stylesheet);
			
			textField.type = TextFieldType.DYNAMIC;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.embedFonts = true;
			textField.wordWrap = true;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.condenseWhite = true;
			textField.multiline = true;
			if (width)
				textField.width = width;
		}
		
		public static function add(d:DisplayObjectContainer, text:String = null, textAttributes:String = null, width:int = 0, height:int = 0, align:String=null, hPad:int = 0, vPad:int = 0):void
		{
			var txt:TextField = new TextField();
			txt.text = text;
			TextUtil.applyTextAttributes(txt, textAttributes);
			if (align)
				DisplayUtils.fitIntoRect(txt, width, height, align);
			else
			{
				txt.x = hPad;
				txt.y = vPad;
			}
			
			d.addChild(txt);
		}
		
		public static function applyTextAttributes(t:TextField, attributesPreset:String, width:int = 0, height:int = 0, beginIndex:int = -1, endIndex:int = -1):void
		{
			var pr:Presets;
			
			var tap:TextAttributeProperties;

			pr = Presets.gi();
			
			if (attributesPreset)
			{
				tap = pr.textAttributePresets.getPropsByName(attributesPreset);
				if (!tap)
					throw new Error("Text: Text attribute not found:" + attributesPreset, tap);
				
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
					t.styleSheet = StyleSheetUtils.getStyleSheetById(tap.stylesheet);
				else if (tap.textformat)
					t.setTextFormat(getTextFormatById(tap.textformat), beginIndex, endIndex);
				else
					throw new Error("Missing textformat for textAttributes: " + tap.name);
			}
		}
		
		public static function getTextFormatById(id:String):TextFormat
		{
			var fp:TextFormatProperties;
			var tf:TextFormat;
			
			if (!textFormats)
				textFormats = new gDictionary();
			else
				tf = textFormats.getByName(id);
			
			if (tf)
				return tf;
			else
			{
				tf = new TextFormat();
				fp = Props.pr.textFormatPresets.getPropsByName(id);
				
				if (!fp)
					throw new Error("TextUtil: no text format for " + id);
					
				tf.align = fp.align;
				tf.blockIndent = fp.blockIndent;
				tf.bold = fp.bold;
				tf.color = fp.color;
				if (fp.font)
				{
					var klass:Class;
					var font:Font;
					
					klass = Resources.getClass(fp.font);
					font = new klass();
					tf.font = font.fontName;
				}
				
				tf.indent = fp.indent;
				tf.italic = fp.italic;
				tf.kerning = fp.kerning;
				tf.leading = fp.leading;
				tf.leftMargin = fp.leftMargin;
				tf.letterSpacing = fp.letterSpacing;
				tf.rightMargin = fp.rightMargin;
				tf.size = fp.size;
				tf.underline = fp.underline;
				return tf;
			}
		}
		
		public static function smoothHtmlBitmaps(txt:TextField):void
		{
			var bm:Bitmap;
			var xml:XML;
			
			xml = new XML(txt.htmlText);
			
			for (var i:int = 0; i < xml.img.length(); ++i)
			{
				var loader:Loader = txt.getImageReference(xml.img[i].@id) as Loader;
				if (loader)
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onHtmlImageLoaded);
			}
		}
		
		private static function onHtmlImageLoaded(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, onHtmlImageLoaded);
			
			Bitmap(event.target.content).smoothing = true;
		}
		
		public static function getUniqueName():String
		{
			_unique += 1;
			return "__" + String(_unique);
		}
		
		public static function getFileExtension(s:String):String
		{
			var nameParts:Array;
			
			nameParts = s.split(".");
			return nameParts[nameParts.length - 1];
		}
		
		public static function stripFileExtenstion(s:String):String
		{
			var nameParts:Array;
			nameParts = s.split(".");
			return nameParts[nameParts.length -2];
		}
		
		public static function formatTime(v:Number):String
		{
			var time:String;
			var sec:int;
			
			time = "";
			if (v > 5940) // hours
				time = String(Math.floor(v / 3600)) + ":";
			
			time += String(Math.floor(v / 60)) + ":";
			
			sec = Math.ceil(v % 60)
			
			if (sec < 10)
				time += "0" + String(sec);
			else
				time += String(Math.ceil(v % 60));
			
			return time;
		}
		
		public static function stripLinks(s:String):String
		{
			var tmp:String;
			
			var linkBegin:int;
			var linkEnd:int;
			
			tmp = s.toLowerCase();
			
			linkBegin = tmp.indexOf("<a href=");
			if (linkBegin != -1)
			{
				linkEnd = tmp.indexOf("</a>");
				if (linkEnd != -1)
				{
					s = s.substr(0, linkBegin) + s.substring(linkEnd + 4);
					s = stripLinks(s);
					return s;
				}
				else
					return s;
			}
			else
				return s;
		}
		
		public static function stripStringSurroundedByDelimiter(str:String, delimiterBegin:String, delimiterEnd:String):String
		{
			var result:String;
						
			process(str);
			return result;
				
			function process(str:String):void
			{
				var begin:int;
				var end:int;
				
				result = str;
				begin = result.indexOf(delimiterBegin);
			
				if (begin != -1)
				{
					end = result.indexOf(delimiterEnd) + delimiterEnd.length;
					result = str.substr(0, begin) + str.substr(end); 
					process(result);
				}
			}
		}
	}
}