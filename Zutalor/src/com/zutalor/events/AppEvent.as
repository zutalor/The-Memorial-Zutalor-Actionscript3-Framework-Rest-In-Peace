/**
* @description  
*/
package com.zutalor.events
{
	import flash.events.Event;
	
	public class AppEvent extends Event {
		
		public static const MENU_CALL:String = "menucall";
		public static const INITIALIZED:String = "initialized";
		
			
		/**
		* @description  Constructor.
		*
		* @param  pType  The event name.
		* @param  pBubbles  Whether the event bubbles up through the display list.
		* @param  pCancelable  Whether the event can be canceled as it bubbles.
		*/
		public function AppEvent(pType:String, pBubbles:Boolean=false, pCancelable:Boolean=false) {
			super(pType, pBubbles, pCancelable);
		}		
	}
}