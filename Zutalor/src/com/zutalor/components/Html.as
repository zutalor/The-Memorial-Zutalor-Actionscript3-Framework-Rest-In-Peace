package com.zutalor.components 
{
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.text.StyleSheets;
	import com.zutalor.text.TextAttributes;
	import com.zutalor.text.TextUtil;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Html extends InputText implements IComponent 
	{		
		override public function render(vip:ViewItemProperties):void
		{
			super.render(vip);
			enabled = false;
			if (vip.url)
				loadHtml(vip.url);
			else
			{
				textField.htmlText = textField.text;
				if (vip.styleSheetName)
						StyleSheets.apply(textField, vip.styleSheetName, vip.width);
			}
		}
		
		override public function get value():*
		{
			return textField.htmlText;
		}
		
		override public function set value(value:*):void
		{
			textField.htmlText = value;
		}
		
		public function loadHtml(url:String, textField:TextField = null, width:int = 0, stylesheet:String = null):void
		{
			var urlLoader:URLLoader = new URLLoader();
			var urlRequest:URLRequest;
			
			urlLoader = new URLLoader();
			urlRequest = new URLRequest(url);
			urlLoader.load(urlRequest);
			urlLoader.addEventListener(Event.COMPLETE, onTextLoadComplete, false, 0, true);

			function onTextLoadComplete(event:Event):void
			{
				event.target.removeEventListener(Event.COMPLETE, _onTextLoadComplete);
				event.target.close();
				if (textField)
				{
					if (stylesheet)
						StyleSheets.apply(textField, stylesheet, width);
					
					textField.htmlText = event.target.data;
					textField.height = textField.textHeight;
					smoothHtmlBitmaps(textField);
				}
				if (_onComplete != null)
					_onComplete();
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
		
		private function onHtmlImageLoaded(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, onHtmlImageLoaded);
			
			Bitmap(event.target.content).smoothing = true;
		}
	}
}