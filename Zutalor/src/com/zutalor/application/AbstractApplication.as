package com.zutalor.application 
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.controllers.DialogController;
	import com.zutalor.events.AppEvent;
	import com.zutalor.loaders.URL;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.ui.Dialog;
	import com.zutalor.utils.StageRef;
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
	
	public class AbstractApplication extends Sprite
	{		
		private var _appController:AppController;
		
		public function AbstractApplication()
		{
			init();
		}
		
		private function init():void
		{
			AppRegistry.initialize();
			AirStatus.initialize();
			Plugins.registerClassAndCreateCachedInstance(DialogController);
		}
		
		public function start(bootXmlUrl:String, splashEmbedClassName:String=null):void
		{
			var paramObj:Object
			var url:String;
			var ip:String;
			
			parent.root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, 
																							onUncaughtError);
			try {
				paramObj = LoaderInfo(this.root.loaderInfo).parameters;
				url = String(paramObj["url"]);
				ip = String(paramObj["ip"]);
			} catch (e:*) { }
		
			if (url != "undefined" && url != "/" && url != null) 
				URL.open("/#/" + url.substring(1), "_self");
				
			_appController = new AppController(bootXmlUrl, ip, splashEmbedClassName);	
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			StageRef.stage = stage;
			stage.stageFocusRect = false;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			for (var i:int = 0; i < stage.numChildren; i++)
				stage.getChildAt(i).visible = false;	
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_appController.addEventListener(AppEvent.INITIALIZED, onInitialized);
			_appController.init();
		}
	
		private function onInitialized(e:Event):void
		{
			_appController.removeEventListener(AppEvent.INITIALIZED, onInitialized);
			dispatchEvent(new AppEvent(AppEvent.INITIALIZED));
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