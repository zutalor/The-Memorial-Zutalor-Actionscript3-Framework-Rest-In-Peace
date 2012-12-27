package com.zutalor.components.html 
{
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.components.text.Text;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.utils.ShowError;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Html extends Text implements IComponent 
	{	
		public function Html(name:String)
		{
			super(name);
		}

		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super.render(viewItemProperties);
			editable = false;
			if (vip.url)
				loadHtml(vip.url);
			else
			{
				textField.htmlText = textField.text;
				if (vip.styleSheetName)
					StyleSheets.apply(textField, vip.styleSheetName, int(vip.width));
				else
					ShowError.fail(Html, "No stylesheet defined for: " + vip.name);
			}
		}
		
		override public function get value():*
		{
			return textField.htmlText;
		}
		
		override public function set value(value:*):void
		{
			if (!value)
				value = "";
				
			textField.htmlText = value;
			StyleSheets.apply(textField, vip.styleSheetName, int(vip.width));			
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
				event.target.removeEventListener(Event.COMPLETE, onTextLoadComplete);
				event.target.close();
				if (textField)
				{
					if (stylesheet)
						StyleSheets.apply(textField, stylesheet, width);
					
					textField.htmlText = event.target.data;
					textField.height = textField.textHeight;
					smoothHtmlBitmaps(textField);
				}
			}
		}
		
		public function smoothHtmlBitmaps(txt:TextField):void
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