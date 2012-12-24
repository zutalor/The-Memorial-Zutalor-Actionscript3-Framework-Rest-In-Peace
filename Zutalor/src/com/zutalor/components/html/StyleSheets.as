package com.zutalor.components.html 
{
	import com.zutalor.loaders.URLLoaderG;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.EmbeddedResources;
	import com.zutalor.utils.ShowError;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class StyleSheets
	{	
		private static var _numLoaded:int;
		private static var _onComplete:Function;
		private static var _presets:PropertyManager;
		
		public static function registerPresets(options:Object):void
		{	
			if (!_presets)
				_presets = new PropertyManager(CssProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		public static function apply(textField:TextField, stylesheet:String, width:Number = 0):void
		{
			textField.styleSheet = getStyleSheetById(stylesheet);	
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
		
		public static function loadCss(onComplete:Function = null):void
		{	
			_onComplete = onComplete;
			_numLoaded = 0;
			for (var i:int = 0; i < _presets.length; i++)
				loadFile(i);
		}
		
		private static function loadFile(indx:int):void
		{		
			var cssProps:CssProperties;
			cssProps = _presets.getPropsByIndex(indx);

			if (cssProps && cssProps.url)
			{
				var loader:URLLoaderG = new URLLoaderG();
				loader.load(cssProps.url, onLoaded);
				
				function onLoaded(lg:URLLoaderG):void
				{
					_numLoaded++;
					setCss(lg.data, indx);
					if (_numLoaded == _presets.length)
					{
						loader.dispose();
						loader = null;
						if (_onComplete != null)
							_onComplete();
					}
				}
				
				function onError(e:Event):void
				{
					ShowError.fail(this,"StyleSheetUtils, could not read: " + e.target.url);
				}
			}
		}
		
		private static function setCss(data:*, indx:int):void
		{
			var cssProps:CssProperties;
			
			cssProps = _presets.getPropsByIndex(indx);
			if (cssProps)
			{
				cssProps.styleSheet = new StyleSheet();
				cssProps.styleSheet.parseCSS(data);
			}
		}
		
		
		public static function getStyleSheetById(id:String):StyleSheet
		{
			var cssProps:CssProperties;
			var s:StyleSheet;
			
			cssProps = _presets.getPropsByName(id);
		
			if (!cssProps)
				ShowError.fail(StyleSheets,"StyleSheet not found: " + id);
			
			s = cssProps.styleSheet;	
				
			var names:Array=s.styleNames;
			var i:int=0;
			var l:int=names.length;
			var so:Object;
			var fc:Class;
			var f:Font;
			var finalFontFamily:String;
			for(i;i<l;i++)
			{
				so=s.getStyle(names[i]);
				for(var key:String in so)
				{
					if(key=="font")
					{
						fc = EmbeddedResources.getClass(so[key]);
						f=new fc();
						delete so[key];
						finalFontFamily=f.fontName;
					}
				}
				if (finalFontFamily)
					so['fontFamily']=finalFontFamily;
				
				s.setStyle(names[i],so);
			}
			return s;
		}
	}
}