/**
* @description  
*/
package com.zutalor.gesture
{
	import flash.events.Event;
	import org.gestouch.gestures.Gesture;
	
	public class AppGestureEvent extends Event {
		
		public static const RECOGNIZED:String = "recognized";
		public var gesture:Gesture;
		public var name:String;
			
		/**
		* @description  Constructor.
		*
		* @param  pType  The event name.
		* @param  pBubbles  Whether the event bubbles up through the display list.
		* @param  pCancelable  Whether the event can be canceled as it bubbles.
		*/
		public function AppGestureEvent(pType:String, pGesture:Gesture, pName:String, pBubbles:Boolean=false, pCancelable:Boolean=false) {
			super(pType, pBubbles, pCancelable);
			gesture = pGesture;
			name = pName;
		}		
	}
}