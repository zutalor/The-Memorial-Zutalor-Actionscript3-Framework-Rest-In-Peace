package com.zutalor.application
{
	import com.zutalor.loaders.URLLoaderG;
	import com.zutalor.properties.Properties;
	import com.zutalor.text.StringUtils;
	import com.zutalor.utils.ShowError;
	import flash.utils.getTimer;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AppXmlLoader
	{
		public static var pr:*;
		public static var useCacheBuster:Boolean = false;
		
		private static var _xmlFiles:int;
		private static var _xmlFilesProcessed:int;
		private static var _loaders:Array;
		private static var _onComplete:Function;
		private static var _initialized:Boolean;
		
		private static var _cacheBuster:String;
		
		public static function init(bootXmlUrl:String, inlineXML:XML, onComplete:Function):void
		{
			var date:Date;
			
			if (_initialized)
			{
				if (onComplete != null)
					onComplete();
				return;
			}
			
			if (useCacheBuster)
			{
				date = new Date();
				_cacheBuster = "?t=" + date.getTime();
			}
			else
				_cacheBuster = "";
			
			_onComplete = onComplete;
			_loaders = [];
			
			if (inlineXML)
				parseProps(inlineXML);
			
			if (bootXmlUrl)
				loadBootXml(bootXmlUrl);
		}
	
		private static function loadBootXml(url:String):void
		{
			var loaderG:URLLoaderG = new URLLoaderG();
			loaderG.load(url + _cacheBuster, onBootLoaded);
		}
		
		private static function onBootLoaded(lg:URLLoaderG):void
		{
			var xml:XML = XML(lg.data);
			
			if (lg.error)
				ShowError.fail(AppXmlLoader, "Could not load: " + lg.url);
			
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
				_loaders[i].load(urls[i] + _cacheBuster, onLoadComplete);
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
				ShowError.fail(AppXmlLoader,"Could not load " + lg.url);
			
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