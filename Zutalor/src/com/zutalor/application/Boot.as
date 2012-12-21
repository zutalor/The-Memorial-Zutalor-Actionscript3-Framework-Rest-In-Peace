package com.zutalor.application 
{
	import com.zutalor.loaders.URLLoaderG;
	import com.zutalor.propertyManagers.Properties;
	import com.zutalor.text.StringUtils;
	import com.zutalor.utils.ShowError;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Boot
	{
		public static var pr:*;
		
		private static var _xmlFiles:int;
		private static var _xmlFilesProcessed:int;
		private static var _loaders:Array;
		private static var _onComplete:Function;
		private static var _initialized:Boolean;
		
		public static function init(bootXmlUrl:String, onComplete:Function):void
		{
			if (_initialized)
			{
				if (onComplete != null)
					onComplete();
				return;
			}
			
			_onComplete = onComplete;
			_loaders = [];		
			loadBootXml(bootXmlUrl);
		}
	
		private static function loadBootXml(url:String):void
		{
			var loaderG:URLLoaderG = new URLLoaderG();
			loaderG.load(url, onBootLoaded);
		}
		
		private static function onBootLoaded(lg:URLLoaderG):void
		{
			var xml:XML = XML(lg.data);
			
			if (lg.error)
				ShowError.fail(Boot, "Could not load: " + lg.url);
			
			parseProps(xml);
			lg.dispose();
			loadXml();
		}
		
		private static function loadXml():void
		{
			var urls:Array = [];
			var path:String;
			
			if (Application.settings.systemXmlUrls)
			{
				urls = Application.settings.systemXmlUrls.split(",");
				path = Application.settings.systemXmlPath;
				addPath(path, urls);
			}	
			
			if (Application.settings.appXmlUrls)
			{
				path = Application.settings.appXmlPath;
				urls = urls.concat(addPath(path, Application.settings.appXmlUrls.split(",")));
			}
			
			_xmlFiles = urls.length;
			_xmlFilesProcessed = 0;
			
			for (var i:int = 0; i < _xmlFiles; i++)
			{
				_loaders[i] = new URLLoaderG();
				_loaders[i].load(urls[i], onLoadComplete);
			}
			
			function addPath(path:String, a:Array):Array
			{
				for (var i:int = 0; i < a.length; i++)
					a[i] = path + StringUtils.stripLeadingSpaces(a[i]);
				
				return a;	
			}
		}
		
		private static function onLoadComplete(lg:URLLoaderG):void
		{
			_xmlFilesProcessed++;
			parseProps(XML(lg.data));
			if (lg.error)
				ShowError.fail(Boot,"Could not load " + lg.url);
			
			if (_xmlFilesProcessed == _xmlFiles)
			{
				for (var i:int = 0; i < _xmlFiles; i++)
				{
					_loaders[i].dispose();
					_loaders[i] = null;
				}
				 _loaders = null;

					_onComplete();
			}
		}
		
		private static function parseProps(xml:XML):void
		{	
			Properties.parseXML(xml);
		}
	}
}