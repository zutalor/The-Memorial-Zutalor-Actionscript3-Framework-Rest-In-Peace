package com.zutalor.controllers
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.events.UIEvent;
	import com.zutalor.interfaces.IUXController;
	import com.zutalor.plugin.constants.PluginClasses;
	import com.zutalor.plugin.constants.PluginMethods;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.ViewControllerRegistry;
	import com.zutalor.view.ViewController;
	import com.zutalor.utils.Logger;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AbstractUXController implements IUXController
	{
		private var _vController:ViewController;
		protected var _currentView:String;		
		
		final public function init(params:Object):void
		{	
			if (!vc) // only first view of the model gets privelages to grab the controller. 
							// Other controllers accessed with controller registry.
			{
				_vController = params["controller"];
			}
			if (AirStatus.isNativeApplication)
			{
				NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);
				NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting); 
			}
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
				NativeApplication.nativeApplication.exit();
			}
		}
		
		public function get message():String
		{
			return null;
		}
		
		public function set message(message:String):void
		{

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
		
		public function setCurrentView(lName:String):void
		{
			_currentView = lName;
		}
		
		public function getCurrentView():String
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
		
		public function closeView(view:String):Boolean
		{
			if (ViewControllerRegistry.getController(view))
			{
				ViewControllerRegistry.getController(view).dispatchUiEvent(UIEvent.CLOSE);
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
		
		public function trackAnalytics(page:String):void
		{
			var tracking:String;
			
			tracking = Props.ap.version + ": " + page;
			if (AirStatus.isNativeApplication)
				Plugins.callMethod(PluginClasses.ANALYTICS, PluginMethods.TRACK_PAGE_VIEW, { page:tracking } );	
		}
				
		public function valueUpdated(params:*):void
		{
			
		}
		
		public function stop():void
		{
			
		}
		
		// PROTECTED METHODS
		
		
		protected function logError(responds:*):void
		{
			for each (var value:String in responds)
				Logger.add(value);
		}		
	}
}