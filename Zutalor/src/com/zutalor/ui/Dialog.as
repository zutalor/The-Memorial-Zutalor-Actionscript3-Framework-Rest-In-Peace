package com.zutalor.ui 
{
	import com.zutalor.plugin.Plugins;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.view.ViewController;
	import com.zutalor.view.ViewControllerRegistry;
	import com.zutalor.view.ViewLoader;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Dialog 
	{
		private static var _callback:Function;
		private static var _lastType:String;
		private static var _progressBar:*;
		private static var _initialized:Boolean;
		private static var _open:Boolean;
		private static var _lastMessage:String;
		
		private static const CLOSED:String = "";
		
		public static const CONFIRM:String = "confirm";
		public static const NOTIFY:String = "notify";
		public static const ALERT:String = "alert";
		public static const PROGRESS:String = "progress";
		public static const IO_ERROR:String = "ioerror";
		public static const DISK_ERROR:String = "diskerror";
		private static const OK:String = "ok";
		private static const CANCEL:String = "cancel";
			
		public static function show(type:String, tMessage:String, callBack:Function = null, percentage:Number = 0):void
		{	
			var vc:ViewController;
			var viewLoader:ViewLoader;
			
			_callback = callBack;
		
			if (type != _lastType)
			{
				if (!_initialized)
				{
					_initialized = true;
					Plugins.callMethod("dialogController", "setOnSelectionCallback", onSelection);
				}
				
				if (!_open)
				{
					_open = true;
					viewLoader = new ViewLoader();
					
					viewLoader.load("dialog", null, onViewLoaded);
					
					function onViewLoaded():void
					{
						vc = ViewControllerRegistry.getController("dialog");
						_progressBar = vc.getItemByName("progressBar");
						_progressBar.x = vc.getItemByName("background").width * .5 - (_progressBar.width * .5);
						Props.uiController.showSheild();
					}
				}
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
			Props.uiController.hideSheild();
			Props.uiController.closeView("dialog");
			_open = false;
			_progressBar.visible = false;
			_lastType = CLOSED;
		}
		
		private static function cancel():void
		{
			onSelection(CANCEL);
		}
		
		// PRIVATE METHODS
				
		private static function onSelection(choice:String = null):void
		{
			close();
			if (_callback != null && choice)
				_callback(choice);
		}
	}
}