package com.zutalor.application
{
	import com.adobe.swffocus.SWFFocus;
	import com.zutalor.air.AirPlugin;
	import com.zutalor.air.AirStatus;
	import com.zutalor.events.AppEvent;
	import com.zutalor.loaders.URL;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.utils.StageRef;
	import com.zutalor.widgets.Dialog;
	import com.zutalor.widgets.RunTimeTrace;
	import flash.desktop.NativeApplication;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	public class Application extends Sprite
	{
		private var _appController:AppController;
		
		protected static var _presets:PropertyManager;
		
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new PropertyManager(ApplicationProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}

		public static function get settings():ApplicationProperties
		{
			return _presets.getPropsByIndex(0);
		}
		
		public function Application()
		{

		}
		
		protected function start(bootXmlUrl:String, inlineXML:XML = null, splashEmbedClassName:String = null,
																							loadingSoundClassName:String = null, PresetInitializer:Class = null):void
		{
			var paramObj:Object
			var url:String;
			var ip:String;
			var agent:String;
			var appPresetInitializer:AppPresetInitializer;
			
			parent.root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,
																							onUncaughtError);
			if (PresetInitializer)
				appPresetInitializer = new PresetInitializer();
			else
				appPresetInitializer = new AppPresetInitializer();
				
			Plugins.registerClassAndCreateCachedInstance(AirPlugin);
			AirStatus.initialize();
																									
			try {
				paramObj = LoaderInfo(this.root.loaderInfo).parameters;
				url = String(paramObj["url"]);
				ip = String(paramObj["ip"]);
				agent = String(paramObj["agent"]);
			} catch (e:*) { }
		
			if (url != "undefined" && url != "/" && url != null)
				URL.open("/#/" + url.substring(1), "_self");
			
			if (!ip || ip == "undefined")
				ip = "IP unknown";
			
			if (!agent || agent == "undefined")
				agent = "Agent Undefined";
				
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			function onAddedToStage(e:Event):void
			{
				StageRef.stage = stage;
				removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				SWFFocus.init(stage);
				
				stage.stageFocusRect = false;
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				
				for (var i:int = 0; i < stage.numChildren; i++)
					stage.getChildAt(i).visible = false;
				
				_appController = new AppController(bootXmlUrl, ip, agent, inlineXML, splashEmbedClassName, loadingSoundClassName, onInitialized);
			}
		}

		protected function onInitialized():void
		{ 
		}
		
		private function onUncaughtError(e:UncaughtErrorEvent):void
		{
			e.preventDefault();
			trace("uncaught error", e.error);
			Dialog.show(Dialog.ALERT, e.error, onConfirm);
			
			function onConfirm():void
			{
				if (AirStatus.isNativeApplication)
					NativeApplication.nativeApplication.exit();
			}
		}
	}
}