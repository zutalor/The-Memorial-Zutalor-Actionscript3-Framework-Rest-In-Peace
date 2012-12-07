package com.zutalor.widgets 
{
	import com.zutalor.plugin.Plugins;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.controller.ViewControllerRegistry;
	import com.zutalor.view.rendering.ViewLoader;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Dialog 
	{
		private static var _callback:Function;
		private static var _lastType:String;
		private static var _progressBar:*;
		private static var _lastMessage:String;
		private static var _vc:ViewController;
		
		private static const CLOSED:String = "";
		
		public static const CONFIRM:String = "confirm";
		public static const NOTIFY:String = "notify";
		public static const ALERT:String = "alert";
		public static const PROGRESS:String = "progress";
		public static const IO_ERROR:String = "ioerror";
		public static const DISK_ERROR:String = "diskerror";
		private static const OK:String = "ok";
		private static const CANCEL:String = "cancel";
		
		public static var sheild:Sprite = new Sprite();
			
		public static function show(type:String, tMessage:String, callBack:Function = null, percentage:Number = 0):void
		{	
			var viewLoader:ViewLoader;
			
			_callback = callBack;
		
			if (type != _lastType)
			{
				if (!_vc)
				{
					Plugins.callMethod("dialogController", "setOnSelectionCallback", onSelection);
					viewLoader = new ViewLoader();
					viewLoader.load("dialog", null, onViewLoaded);
					
					function onViewLoaded():void
					{
						_vc = ViewControllerRegistry.getController("dialog");
						_progressBar = _vc.getItemByName("progressBar");
						_progressBar.x = _vc.getItemByName("background").width - _progressBar.width * .5;
					}
				}
				else
					StageRef.stage.addChild(_vc.container);

				showSheild();
				Plugins.callMethod("dialogController", "open", type);
				_lastType = type;
			}
					
			if (percentage)
			{
				_progressBar.visible = true;
				_progressBar.scaleX = percentage;
			}
			else
				_progressBar.visible = false;

			if (tMessage != _lastMessage)	
				Plugins.callMethod("dialogController", "setMessage", tMessage);
			
			_lastMessage = tMessage;	
		}
		
		public static function close():void
		{
			hideSheild();
			_progressBar.visible = false;
			_lastMessage = null;
			_lastType = CLOSED;
			_vc.container.visible = false;
		}
		
		private static function cancel():void
		{
			onSelection(CANCEL);
		}
		
		// PRIVATE METHODS
		
		private static function showSheild():void
		{
			sheild.graphics.clear();
			sheild.graphics.beginFill(0x000000, .2)
			sheild.graphics.drawRect(0, 0, StageRef.stage.stageWidth, StageRef.stage.stageHeight)
			sheild.graphics.endFill();
			sheild.name = "__Sheild";
			StageRef.stage.addChild(sheild);
		}
		
		private static function hideSheild():void
		{
			if (StageRef.stage.getChildByName("__Sheild"))
				StageRef.stage.removeChild(sheild);
		}		
		
		private static function onSelection(choice:String = null):void
		{
			close();
			if (_callback != null && choice)
				_callback(choice);
		}
	}
}