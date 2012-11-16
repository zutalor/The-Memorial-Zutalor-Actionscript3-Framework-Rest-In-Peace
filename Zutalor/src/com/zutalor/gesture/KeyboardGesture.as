package com.zutalor.gesture 
{
	import com.zutalor.utils.KeyUtils;
	import flash.events.KeyboardEvent;
	import org.gestouch.core.GestureState;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.AbstractDiscreteGesture;
	import org.gestouch.gestures.TapGesture;
	/**
	 * ...
	 * @author Geoff
	 */
	public class KeyboardGesture extends AbstractDiscreteGesture
	{
		public var char:String;
		private var _target:Object;
		
		public function KeyboardGesture(target:Object = null) 
		{
			super(target);
			_target = target;
			target.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
		}
		
		override public function dispose():void
		{
			super.dispose();
			_target.removeEventListener(KeyboardEvent.KEY_UP, onKey);
		}
				
		override public function reflect():Class
		{
			return KeyboardGesture;
		}
		
		private function onKey(ke:KeyboardEvent):void
		{ 	
			char = KeyUtils.shortCutForKeyCode(ke.keyCode);
			if (char == null)
				char = String.fromCharCode(ke.charCode);
			
			if (ke.ctrlKey)
				char += "+" + KeyUtils.CONTROL;
			
			if (ke.altKey)
				char += "+" + KeyUtils.ALT;
			
			if (ke.shiftKey)
				char += "+" + KeyUtils.SHIFT;
			
			if (ke.commandKey)
				char += "+" + KeyUtils.COMMAND;
			
			dispatchEvent(new GestureEvent(GestureEvent.GESTURE_RECOGNIZED, 
											GestureState.RECOGNIZED, GestureState.POSSIBLE));
		}
	}
}