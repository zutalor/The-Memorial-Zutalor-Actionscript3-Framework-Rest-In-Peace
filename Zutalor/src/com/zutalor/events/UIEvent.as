/**
* @description  
*/
package com.zutalor.events
{

	import flash.events.Event;
	
	public class UIEvent extends Event {
		
		public static const CLOSE:String = "close";
		public static const MENU_SELECTION:String = "menuselection";
		public static const FULLSCREEN:String = "fullscreen";
		public static const MINIMIZE:String = "minimize";
		public static const MAXIMIZE:String = "maximize";
		public static const ZOOM_IN:String = "zoomin";
		public static const ZOOM_OUT:String = "zoomout";
		public static const CREATE:String = "create";
		public static const READ:String = "read";
		public static const LAST:String = "last";
		public static const FIRST:String = "first";
		public static const UPDATE:String = "update";
		public static const PURGE:String = "purge";
		public static const NEXT:String = "next";
		public static const PREVIOUS:String = "previous";
		public static const PLAY:String = "play";
		public static const CUE_UP:String = "cueUp";
		public static const PLAY_TOGGLE:String = "playToggle";
		public static const SELECT:String = "select";
		public static const STOP:String = "stop";
		public static const STOP_ALL:String = "stopAll";
		public static const CANCEL:String = "cancel";
		public static const RECYCLE:String = "recycle";
		public static const FF:String = "ff";
		public static const REW:String = "rew";
		public static const PAUSE:String = "pause";
		public static const SEEK:String = "seek";
		public static const VOLUME:String = "volume";
		public static const MUTE_TOGGLE:String = "muteToggle";
		public static const VALUE_CHANGED:String = "value_changed";
		
		public static const NATIVE_WINDOW_CLOSE:String = "native_window_close";
		public static const NATIVE_APPLICATION_EXIT:String = "native_application_exit";
		public static const NATIVE_WINDOW_MOVE:String = "native_window_move";
		public static const NATIVE_WINDOW_MAXIMIZE:String = "native_window_maximize";
		public static const NATIVE_WINDOW_MINIMIZE:String = "native_window_minimize";
		
		private var _type:String;
		private var _viewName:String;
		private var _menuSelection:String;
		private var _itemName:String;
		private var _value:*;
		private var _bubbles:Boolean;
		private var _cancelable:Boolean;
			
		/**
		* @description  Constructor.
		*
		* @param  pType  The event name.
		* @param  pBubbles  Whether the event bubbles up through the display list.
		* @param  pCancelable  Whether the event can be canceled as it bubbles.
		* 
		*/
		public function UIEvent(pType:String, pViewName:String=null, pMenuSelection:String=null, pItemName:String=null, pValue:*=null, pBubbles:Boolean=true, pCancelable:Boolean=false) {
			super(pType, pBubbles, pCancelable);
			_type = pType;
			_bubbles = pBubbles;
			_cancelable = pCancelable;
			_viewName = pViewName;
			_menuSelection = pMenuSelection;
			_itemName = pItemName;
			_value = pValue;
		}
		
		override public function clone():Event
		{
			return new UIEvent(_type, _viewName, _menuSelection, _itemName, _value, _bubbles, _cancelable );
		}
		
		public function get viewName():String
		{
			return _viewName;
		}
		
		public function get itemName():String
		{
			return _itemName
		}
		
		public function get menuSelection():String
		{
			return _menuSelection;
		}
		
		public function get value():*
		{
			return _value;
		}
	}
}