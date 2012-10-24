package com.plagro.processors
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.text.TextField;

	/**
	 * CSSLoader simplifies the Adobe methodology for parsing an external CSS file
	 * 
	 * @author The Burned Out Hippy (adapted from Adobe Helpdocs)
	 * @example http://www.burnedouthippy.com/
	 * 
	 */ 
	
	public class CSSLoader extends Sprite
	{
		
		private var loader:URLLoader;
        private var field:TextField;
        private var theText:String;
        
        /**
		 * Constructor
		 * 
		 * @param	tF			the location of the textfield to output the processed text
		 * @param	t			the text to process
		 * @param	cssFile		the name/path/url of the css file to use
		 * 
		 */ 
		
		public function CSSLoader(tF:TextField, t:String, cssFile:String):void
		{
			field = tF;
			theText = t;                    
            var req:URLRequest = new URLRequest(cssFile);
            
            loader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, onCSSFileLoaded);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
            loader.load(req);
		}
		
		public function onCSSFileLoaded(event:Event):void
        {
            var sheet:StyleSheet = new StyleSheet();
            sheet.parseCSS(loader.data);
            field.styleSheet = sheet;
            field.htmlText = theText;
        }
		
		public function onIOError (e:IOErrorEvent):void
		{
			trace("----------------- [ CSSLoader Message ] -----------------");
			trace("The following error occured: ", e.text);
			trace("PLEASE NOTE:");
			trace("The most common IOError is spelling mistakes in filenames");
			trace("---------------------------------------------------------");
		}
		
	}
}
