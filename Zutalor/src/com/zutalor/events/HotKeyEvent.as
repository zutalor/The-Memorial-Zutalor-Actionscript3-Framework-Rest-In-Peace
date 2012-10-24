/**
* @description  
*/
package com.zutalor.events
{

	import flash.events.Event;
	
	public class HotKeyEvent extends Event {
		
		public static const HOTKEY_PRESS:String = "hotkeypressed";
		
		private var _message:String; 
		
		/**
		* @description  Constructor.
		*
		* @param  pType  The event name.
		* 
		* @param  pBubbles  Whether the event bubbles up through the display list.
		* @param  pCancelable  Whether the event can be canceled as it bubbles.
		*/
		public function HotKeyEvent(
			pType:String,
			pMessage:String,
			pBubbles:Boolean=false,
			pCancelable:Boolean=false
		) {
			super(pType, pBubbles, pCancelable);
			_message = pMessage;
		}
		
		/**
		* @description  Returns a copy of the event instance.
		*
		* @returns  A copy of the event.
		*/
		override public function clone():Event {
			return new HotKeyEvent (
				type,
				_message,
				bubbles,
				cancelable
			);
		}

		/**
		* @description
		*
		* @returns  
		*/
	
		public function get message():String { return _message; }
	}
}