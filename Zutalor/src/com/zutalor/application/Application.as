package com.zutalor.application
{
	import com.adobe.swffocus.SWFFocus;
	import com.zutalor.air.AirPlugin;
	import com.zutalor.air.AirStatus;
	import com.zutalor.loaders.URL;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.utils.StageRef;
	import com.zutalor.widgets.Dialog;
	import flash.display.StageDisplayState;
	import flash.events.SoftKeyboardEvent;

	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.UncaughtErrorEvent;
	
	CONFIG::air
	{
		import flash.desktop.NativeApplication;	
	}

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	public class Application extends EventDispatcher
	{
		public var bootXmlUrl:String;
		public var inlineXML:XML
		public var splashEmbedClassNameSD:String;
		public var splashEmbedClassNameHD:String;
		public var loadingSoundClassName:String;
		public var PresetInitializer:Class;
		public var onInitialized:Function;
		public var ip:String;
		public var agent:String;
		public var main:Sprite;
		
		
		private var _onInitialized:Function;
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
		
		public function Application(pMain:Sprite)
		{
			main = pMain;
			main.root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,
																							onUncaughtError);
		}
		
		public function start(pBootXmlUrl:String = null):void
		{
			var paramObj:Object
			var url:String;
			var appPresetInitializer:AppPresetInitializer;
			
			bootXmlUrl = pBootXmlUrl;
			main.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			if (PresetInitializer)
				appPresetInitializer = new PresetInitializer();
			else
				appPresetInitializer = new AppPresetInitializer();
			
			CONFIG::air {
				Plugins.registerClassAndCreateCachedInstance(AirPlugin);
			}
	
			AirStatus.initialize();
																									
			try {
				paramObj = LoaderInfo(main.root.loaderInfo).parameters;
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
		}
		
		private function onAddedToStage(e:Event):void
		{
			var stage:Stage;
			
			stage = StageRef.stage = main.stage;
			main.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_appController = new AppController(this);

			/*SWFFocus.init(stage);
			stage.stageFocusRect = false;
			for (var i:int = 0; i < stage.numChildren; i++)
				stage.getChildAt(i).visible = false;*/

		}
		
		private function onUncaughtError(e:UncaughtErrorEvent):void
		{
			e.preventDefault();
			trace("uncaught error", e.error);
			Dialog.show(Dialog.ALERT, e.error, onConfirm);
			
			function onConfirm():void
			{
				CONFIG::air
				{
					if (AirStatus.isNativeApplication)
						NativeApplication.nativeApplication.exit();
				}
			}
		}
	}
}