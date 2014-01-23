package com.zutalor.application
{
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.utils.MapXML;
	import com.zutalor.utils.StageRef;
	import com.zutalor.widgets.Focus;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */

	public class ApplicationProperties extends PropertiesBase
	{
		public var appName:String;
		public var version:String;
		public var release:String;
		public var production:Boolean;
		public var ip:String;
		public var agent:String;
		public var designWidth:int;
		public var designHeight:int;
		public var colorTheme:String;
		public var defaultStyleSheetName:String;
		public var proxyLocationUrl:String;
		public var loadingSequenceName:String;
		public var firstState:String;
		public var language:String;
		public var gateway:String;
		public var spinnerSoundClassName:String;
		public var spinnerSoundInterval:int;
		public var spinnerGraphicId:String;
		public var spinnerGraphicCyclesPerSecond:Number;
		public var appXmlPath:String;
		public var systemXmlPath:String;
		public var appXmlUrls:String;
		public var systemXmlUrls:String;
		public var textToSpeechDirectApi:String;
		public var textToSpeechProxyApi:String;
		public var enableTextToSpeech:Boolean;
		public var stageVideoAvailable:Boolean;
		public var googleAnalyticsAccount:String;
		public var googleAnalyticsTestAccount:String;
		public var showFocus:Boolean;
				
		//air & phone related
		
		public var portrait:Boolean;
		public var targetMobile:Boolean;
		public var targetTenPointOne:Boolean;
		
		public function ApplicationProperties() {}
	
		override public function parseXML(xml:XML):Boolean
		{
			var path:String;
			
			MapXML.attributesToClass(xml , this);
			name = name.toLowerCase();
				
			if (!language)
				language = "en";
			
			if (!colorTheme)
				colorTheme = "default";
			
			if (!defaultStyleSheetName)
				defaultStyleSheetName = "default";
			
			Focus.enabled = showFocus;
		
			return true;
		}
	}
}