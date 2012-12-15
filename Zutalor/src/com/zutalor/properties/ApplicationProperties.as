package com.zutalor.properties
{
	import com.zutalor.text.StringUtils;
	import com.zutalor.utils.Singleton;
	import com.zutalor.widgets.Focus;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
//okay, this could be re-done by making this a PropertyManager with auto xml to variable enumeration and all that.
//However this class was one of the first classes for the engine. Keeping for nostalgia purpose. Plus it works.

	public class ApplicationProperties
	{	
		public var appName:String;
		public var version:String;
		public var ip:String;
		public var designWidth:int;
		public var designHeight:int;
		public var colorTheme:String;
		public var defaultStyleSheetName:String;
		public var proxyLocationUrl:String;
		public var loadingSequenceName:String;
		public var firstState:String;
		public var language:String;
		public var gateway:String;
		public var spinningpresetId:String;
		public var spinningGraphicCyclesPerSecond:Number;
		public var appXmlPath:String;
		public var systemXmlPath:String;
		public var appXmlUrls:String;
		public var systemXmlUrls:String;
		public var textToSpeechApiUrlMobile:String;
		public var textToSpeechApiUrlPC:String;
		public var enableTextToSpeech:Boolean;
		public var stageVideoAvailable:Boolean;
		public var useStageVideoIfAvailable:Boolean;
		public var showFocus:Boolean;
				
		//air & phone related
		
		public var googleAnalyticsAccount:String;
		public var portrait:Boolean;
		public var targetPortable:Boolean;		
		
		private static var _applicationProperties:ApplicationProperties;
					
		public function ApplicationProperties() 
		{
			Singleton.assertSingle(ApplicationProperties);
		}
		
		public static function gi():ApplicationProperties
		{
			if (!_applicationProperties)
				_applicationProperties = new ApplicationProperties();
			
			return _applicationProperties;
		}
	
		public function parseXML(appSettings:XMLList):void
		{	
			var path:String;
			
			designWidth = appSettings.design.@width;
			designHeight = appSettings.design.@height;
			language = appSettings.language.@value;
			if (!language)
				language = "English";
			
			proxyLocationUrl = appSettings.proxyLocation.@url;
			
			colorTheme = appSettings.colorTheme.@value;
			if (!colorTheme)
				colorTheme = "default";
			
			firstState = appSettings.firstState.@value;
			loadingSequenceName = appSettings.loadingSequenceName.@value;
						
			defaultStyleSheetName = appSettings.defaultStyleSheetName.@value;
			
			if (!defaultStyleSheetName)
				defaultStyleSheetName = "default";
			
			useStageVideoIfAvailable = appSettings.useStageVideoIfAvailable.@value;	
				
			gateway = appSettings.gateway.@value;
		
			googleAnalyticsAccount = appSettings.googleAnalyticsAccount.@value;
			
			appName = appSettings.appName.@value;
			version = appSettings.version.@value;
			targetPortable = StringUtils.toBoolean(appSettings.targetPortable.@value);
			
			spinningpresetId = appSettings.spinningpresetId.@value;
			spinningGraphicCyclesPerSecond = appSettings.spinningGraphicCyclesPerSecond.@value;
			
			appXmlUrls = appSettings.appXmlUrls.@value;
			appXmlPath = appSettings.appXmlPath.@value;
			systemXmlUrls = appSettings.systemXmlUrls.@value;
			systemXmlPath = appSettings.systemXmlPath.@value;
			
			portrait = StringUtils.toBoolean(appSettings.portrait.@value);
			
			Focus.enabled = StringUtils.toBoolean(appSettings.showFocus.@value);
		
			textToSpeechApiUrlMobile = appSettings.textToSpeechApiUrlMobile.@value;
			textToSpeechApiUrlPC = appSettings.textToSpeechApiUrlPC.@value;
			enableTextToSpeech = StringUtils.toBoolean(appSettings.enableTextToSpeech.@value);
		}
	}
}