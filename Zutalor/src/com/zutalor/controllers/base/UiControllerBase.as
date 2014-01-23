package com.zutalor.controllers.base
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.events.UIEvent;
	import com.zutalor.interfaces.IUiController;
	import com.zutalor.plugin.constants.PluginClasses;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.utils.Logger;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.controller.ViewControllerRegistry;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	CONFIG::air
	{
		import flash.desktop.NativeApplication;
	}	
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class UiControllerBase implements IUiController
	{
		private var _vController:ViewController;
		private var _currentView:String;
		
		public function UiControllerBase() {}
		
		final public function init(params:Object):void
		{
			if (!vc) // only first view of the model gets privelages to grab the controller.
							// Other controllers accessed with controller registry.
			{
				_vController = params["controller"];
			}
			
			if (AirStatus.isNativeApplication)
			{
				CONFIG::air {
					NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);
					NativeApplication.nativeApplication.addEventListener("suspend", onDeactivate);
					NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
				}
				var t:int; // put this here to get compiler to not issue warning about empty block.
			}
        }

		public function logEvent(e:String, data:* = null):void
		{
			
		}
		
        private function onKeyDown(e:KeyboardEvent):void
        {
			e.preventDefault();
			switch (e.keyCode)
			{
				case Keyboard.BACK :
					onBackKey();
					break;
				case Keyboard.SEARCH :
					onSearchKey();
					break;
				case Keyboard.MENU :
					onMenuKey();
					break;
			}
		}
		
		// PUBLIC METHODS
		
		public function exit():void
		{
			if (AirStatus.isNativeApplication)
			{
				var t:int; // put this here to get compiler to not issue warning about empty block.

				CONFIG::air
				{
					NativeApplication.nativeApplication.exit();
				}
			}
		}
				
		public function onSearchKey():void
		{
			
		}
		
		public function onBackKey():void
		{
			
		}
		
		public function onMenuKey():void
		{
			
		}
		
		public function onDeactivate(e:Event):void
		{
			
		}
		
		public function onExiting(e:Event):void
		{
		}
		
		public function get vc():ViewController
		{
			return _vController;
		}
		
		public function set currentView(lName:String):void
		{
			_currentView = lName;
		}
		
		public function get currentView():String
		{
			return _currentView;
		}
		
		public function getValueObject(params:Object=null):*
		{
			return null;
		}
		
		public function onModelChange(args:*=null):void
		{
			_vController.onModelChange(args);
		}
		
		public function onModelError(responds:*=null):void
		{
			_vController.onModelError(responds);
			Logger.add(responds);
		}
		
		public function hideView(view:String, useTransition:Boolean=true):Boolean
		{
			if (ViewControllerRegistry.getController(view))
			{
				ViewControllerRegistry.getController(view).hide(useTransition);
				return true;
			}
			else
				return false;
		}
		
		public function isViewVisible(view:String):Boolean
		{
			return ViewControllerRegistry.getController(view).container.visible;
		}
		
		public function showView(view:String, useTransition:Boolean=true):Boolean
		{
			if (ViewControllerRegistry.getController(view))
			{
				ViewControllerRegistry.getController(view).show(useTransition);
				return true;
			}
			else
				return false;
		}
		
		public function onItemFocusIn(params:*):void
		{
			
		}
		
		public function dispose():void
		{
			
		}
		
		public function onKey(key:*):void
		{
			
		}
				
		public function valueUpdated(params:*):void
		{
			
		}
		
		public function stop(message:String = null):void
		{
			
		}
	}
}