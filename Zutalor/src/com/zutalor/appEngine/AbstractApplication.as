package com.zutalor.appEngine 
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.controllers.DialogController;
	import com.zutalor.controllers.UIController;
	import com.zutalor.events.AppEvent;
	import com.zutalor.loaders.URL;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.ui.Dialog;
	import com.zutalor.utils.Path;
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
	
	public class AbstractApplication extends Sprite
	{		
		private var _ip:String;
		private var _uiController:UIController;
		private var _hasInitiated:Boolean;
		
		public function start(bootXmlUrl:String, splashEmbedClassName:String=null):void
		{
			var url:String;
			
			Plugins.registerClassAndCreateCachedInstance(DialogController);
			
			try {
				var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
				_ip = String(paramObj["ip"]);
				url = String(paramObj["url"]);
			} catch (e:*) { }
		
			if (url != "undefined" && url != "/" && url != null) 
				URL.open("/#/" + url.substring(1), "_self");
			else
			{
				AirStatus.initialize();
				_uiController = new UIController(bootXmlUrl, splashEmbedClassName);
				Props.uiController = _uiController;
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}
		
		private function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.stageFocusRect = false;
			initPaths();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			for (var i:int = 0; i < stage.numChildren; i++)
				stage.getChildAt(i).visible = false;
				
			parent.root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, 
																							onUncaughtError); 
			_uiController.addEventListener(AppEvent.INITIALIZED, onInitialized);
			_uiController.init(stage, _ip);	
		}
	
		private function onInitialized(e:Event):void
		{
			_uiController.removeEventListener(AppEvent.INITIALIZED, onInitialized);
			dispatchEvent(new AppEvent(AppEvent.INITIALIZED));
		}
			
		private function onUncaughtError(e:UncaughtErrorEvent):void
		{
			e.preventDefault();
			Dialog.show(Dialog.ALERT, e.error, onConfirm);
			
			function onConfirm():void
			{
				//if (AirStatus.isNativeApplication)
					//NativeApplication.nativeApplication.exit(); 
			}
		}
		
		private function initPaths():void
		{
			Path.addPath("assets", "assets/");
			Path.addPath("bitmaps", "assets/bitmaps/");
			Path.addPath("pages", "assets/pages/");
			Path.addPath("video", "assets/video/");
			Path.addPath("systemXml","xml/system/");
			Path.addPath("appXml","xml/app/");
			Path.addPath("html", "assets/html/");
			Path.addPath("audio", "assets/audio/");
			Path.addPath("css", "css/");
			
			if (AirStatus.isNativeApplication)
			{
				//var file:File = File.applicationStorageDirectory;
				//Path.addPath("appStorage", file.url);
			}
		}
	}
}