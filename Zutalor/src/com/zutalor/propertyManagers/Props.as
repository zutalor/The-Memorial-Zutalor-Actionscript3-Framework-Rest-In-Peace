package com.zutalor.propertyManagers 
{
	import com.zutalor.components.html.StyleSheets;
	import com.zutalor.loaders.URLLoaderG;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.FiltersItemProperties;
	import com.zutalor.properties.FiltersProperties;
	import com.zutalor.properties.PlaylistItemProperties;
	import com.zutalor.properties.PlaylistProperties;
	import com.zutalor.utils.ShowError;
	import com.zutalor.utils.StringUtils;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Props
	{
		public static var ap:ApplicationProperties;
		public static var pr:*;
		
		public static var playlists:NestedPropsManager;
		public static var filters:NestedPropsManager;

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
			pr = Presets;	
			ap = ApplicationProperties.gi();
			filters = new NestedPropsManager();
			playlists = new NestedPropsManager();
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
				ShowError.fail(Props, "Could not load: " + lg.url);
			
			ap.parseXML(xml.appSettings);
			parseProps(xml);
			lg.dispose();
			loadXml();
		}
		
		private static function loadXml():void
		{
			var urls:Array = [];
			var path:String;
			
			if (ap.systemXmlUrls)
			{
				urls = ap.systemXmlUrls.split(",");
				path = ap.systemXmlPath;
				addPath(path, urls);
			}	
			
			if (ap.appXmlUrls)
			{
				path = ap.appXmlPath;
				urls = urls.concat(addPath(path, ap.appXmlUrls.split(",")));
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
				ShowError.fail(Props,"Could not load " + lg.url);
			
			if (_xmlFilesProcessed == _xmlFiles)
			{
				for (var i:int = 0; i < _xmlFiles; i++)
				{
					_loaders[i].dispose();
					_loaders[i] = null;
				}
				 _loaders = null;

				StyleSheets.loadCss(onCssLoaded);
				
				function onCssLoaded():void
				{
					_onComplete();
				}
			}
		}
		
		private static function parseProps(xml:XML):void
		{	

			playlists.parseXML(PlaylistProperties, PlaylistItemProperties, xml.playlists, "playlist", xml.playlist, "props");						
			Presets.parseXML(xml);		
			
			
			filters.parseXML(FiltersProperties, FiltersItemProperties, xml.filters, "filter", xml.filter, "props");
		}
	}
}