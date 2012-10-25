package com.zutalor.text 
{
	import com.zutalor.loaders.URLLoaderG;
	import com.zutalor.properties.CssProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.Resources;
	import com.zutalor.utils.StringUtils;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.Font;
	import flash.text.StyleSheet;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class StyleSheetUtils 
	{	
		private static var _numLoaded:int;
		private static var _onComplete:Function;
		
		public static function loadCss(onComplete:Function):void
		{	
			_onComplete = onComplete;
			_numLoaded = 0;
			for (var i:int = 0; i < Props.pr.cssPresets.length; i++)
				loadFile(i);
		}
		
		private static function loadFile(indx:int):void
		{		
			var cssProps:CssProperties;
			cssProps = Props.pr.cssPresets.getPropsByIndex(indx);

			if (cssProps && cssProps.url)
			{
				var loader:URLLoaderG = new URLLoaderG();
				loader.load(cssProps.url, onLoaded);
				
				function onLoaded(lg:URLLoaderG):void
				{
					_numLoaded++;
					setCss(lg.data, indx);
					if (_numLoaded == Props.pr.cssPresets.length)
					{
						loader.dispose();
						loader = null;
						_onComplete();
					}
				}
				
				function onError(e:Event):void
				{
					throw new Error("StyleSheetUtils, could not read: " + e.target.url);
				}
			}
		}
		
		private static function setCss(data:*, indx:int):void
		{
			var cssProps:CssProperties;
			
			cssProps = Props.pr.cssPresets.getPropsByIndex(indx);
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
			
			cssProps = Props.pr.cssPresets.getPropsByName(id);
		
			if (!cssProps)
				throw new Error("StyleSheet not found: " + id);
			
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
						fc = Resources.getClass(so[key]);
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
		
		/**
		 * Get a color in hex with 0x, (0xff0066).
		 * 
		 * @param selector The select from the "colors" stylesheet.
		 * 
		 * @see #getColorAsInt The getColorAsInt function for more documentation.
		 */
		
		public static function getColorAs0xHexString(selector:String):String
		{
			if(!selector)return "0x";
			var s:StyleSheet=getStyleSheetById("colors");
			if(!s)throw new Error("A styleshee in the model name 'colors' must be defined.");
			var c:String=s.getStyle(selector).color;
			if(!c)trace("WARNING: The selector {"+selector+"} in the colors stylesheet wasn't found.");
			return StringUtils.styleSheetNumberTo0xHexString(c);
		}
		
		/**
		 * Get a color in hex with #, (#ff0066).
		 * 
		 * @param selector The select from the "colors" stylesheet.
		 * 
		 * @see #getColorAsInt The getColorAsInt function for more documentation.
		 */
		public static function getColorAsPoundHexString(selector:String):String
		{
			var s:StyleSheet=getStyleSheetById("colors");
			if(!s)throw new Error("A styleshee in the model name 'colors' must be defined.");
			var c:String=s.getStyle(selector).color;
			if(!c)
			{
				trace("WARNING: The selector {"+selector+"} in the colors stylesheet wasn't found.");
				return "#FFFFFF";
			}
			return c;
		}
		
		public static function mergeStyleSheets(...sheets:Array):StyleSheet
		{
			if(sheets[0] is Array)sheets=sheets[0];
			var newstyles:StyleSheet=new StyleSheet();
			var i:int=0;
			var l:int=sheets.length;
			var k:int;
			var j:int;
			var sn:String;
			for(i;i<l;i++)
			{
				var s:StyleSheet=StyleSheet(sheets[i]); 
				var nm:Array=s.styleNames;
				k=0;
				j=nm.length;
				for(k;k<j;k++)
				{
					sn=nm[k];
					newstyles.setStyle(sn,s.getStyle(sn));
				}
			}
			return newstyles;
		}
	}
}