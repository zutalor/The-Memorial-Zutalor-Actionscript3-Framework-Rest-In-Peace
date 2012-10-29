package com.zutalor.gesture 
{
	import com.zutalor.utils.GetShortCut;
	import com.zutalor.utils.StageRef;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.LongPressGesture;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.RotateGesture;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.TransformGesture;
	import org.gestouch.gestures.ZoomGesture;
	/**
	 * ...
	 * @author Geoff
	 */
	public class GestureManager
	{		
		public static const LONG_PRESS:String = "longpress";
		public static const PAN:String = "pan";
		public static const ROTATE:String = "rotate";
		public static const SWIPE:String = "swipe";
		public static const TRANSFORM:String = "transform";
		public static const ZOOM:String = "zoom";
		public static const TAP:String = "tap";
		public static const DOUBLE_TAP:String = "doubletap";
		public static const KEY_PRESS:String = "keypress";
		
		private var _dict:Dictionary;
		private var _target:*;
		private var _gesture:*;
		private var _callback:Function;
				
		public function InputManager() 
		{
		}
		
		public function dispose():void
		{	
			for (var target:Object in _dict)
			{
				for (var gestureId:Object in _dict[target])
				{
					for (var callback:Object in _dict[target][gestureId])
						removeListeners(_dict[target][gestureId][callback]);	

					_dict[target][gestureId] = null;
				}
				_dict[target] = null;
			}
			_dict = null;
		}
		
		public function removeCallback(target:*, type:String, callback:Function):void
		{
			var gestureId:*;
			
			switch (type)
			{
				case KEY_PRESS :
					gestureId = onKey;
					break;
				case TAP :
				case DOUBLE_TAP :
					gestureId = TapGesture; 
					break;
				case LONG_PRESS :
					gestureId = LongPressGesture;
					break;
				case PAN :
					gestureId = PanGesture;
					break;
				case ROTATE :
					gestureId = RotateGesture;
					break;
				case SWIPE :
					gestureId = SwipeGesture;
					break;
				case TRANSFORM :
					gestureId = TransformGesture;
					break;
				case ZOOM :
					gestureId = ZoomGesture;
					break;				
			}
			removeListeners(_dict[target][gestureId][callback]);
		}
		
		public function addCallback(target:*, type:String, callback:Function):void
		{
			var ip:InputProperties;
			
			_target = target;
			_callback = callback;

			switch (type)
			{
				case KEY_PRESS :
					ip = new InputProperties();
					ip.gesture = onKey;
					ip.gestureId = onKey;
					ip.callback = _callback;
					ip.target = StageRef.stage;
					ip.target.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
					ip.listeners.push(KeyboardEvent.KEY_DOWN);
					ip.listeners.push(KeyboardEvent.KEY_UP);
					addToDict(ip);
					break;
				case TAP :
				case DOUBLE_TAP :
					ip = new InputProperties();
					ip.gesture = new TapGesture(_target);
					ip.gestureId = TapGesture; 
					ip.target = _target;
					ip.callback = _callback;
					if (type == DOUBLE_TAP)
					{
						ip.gesture.numTapsRequired = 2;
						ip.gesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onGesture, false, 0, true)
					}
					else
					{
						ip.gesture.numTapsRequired = 1;
						ip.gesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onGesture, false, 0, true)
					}	
					ip.listeners.push(GestureEvent.GESTURE_RECOGNIZED);
					addToDict(ip);
					break;
				case LONG_PRESS :
					addGestureListener(LongPressGesture);
					break;
				case PAN :
					addGestureListener(PanGesture);
					break;
				case ROTATE :
					addGestureListener(RotateGesture);
					break;
				case SWIPE :
					addGestureListener(SwipeGesture);
					break;
				case TRANSFORM :
					addGestureListener(TransformGesture);
					break;
				case ZOOM :
					addGestureListener(ZoomGesture);
					break;				
			}
		}
		
		// private methods
		
		private function addGestureListener(gesture:Class):void
		{
			var ip:InputProperties;
			
			ip = new InputProperties;
			ip.callback = _callback;
			ip.gesture = new gesture(_target);
			ip.gestureId = gesture;
			ip.target = _target;
			ip.gesture.addEventListener(GestureEvent.GESTURE_BEGAN, onGesture);
			ip.gesture.addEventListener(GestureEvent.GESTURE_CHANGED, onGesture);
			ip.listeners.push(GestureEvent.GESTURE_BEGAN);
			ip.listeners.push(GestureEvent.GESTURE_CHANGED);		
			addToDict(ip);	
		}
		
		private function addToDict(ip:InputProperties):void
		{
			if (!_dict)
				_dict = new Dictionary;
			
			if (!_dict[ip.target])
				_dict[ip.target] = new Dictionary();

			if (!_dict[ip.target][ip.gestureId])
				_dict[ip.target][ip.gestureId] = new Dictionary;
			
			removeListeners(_dict[ip.target][ip.gestureId][ip.callback]); // just in case
			_dict[ip.target][ip.gestureId][ip.callback] = ip;
		}
		
		private function removeListeners(ip:InputProperties):void
		{
			if (ip)
			{
				if (ip.gesture is Function)
					ip.target.removeEventListener(ip.listeners[0], onKey);
				else
				{
					for (var i:int = 0; i < ip.listeners.length; i++)
					{
						ip.gesture.removeEventListener(ip.listeners[i], onGesture);
						ip.gesture.dispose();
					}
				}
				ip.listeners = [];
				_dict[ip.target][ip.gestureId][ip.callback] = null;
			}
		}
		
		private function onKey(ke:KeyboardEvent):void
		{
			var char:String;
			
			char = GetShortCut.forKey(ke.keyCode);
			if (char == null) 
				char = String.fromCharCode(ke.charCode);
	
			if (ke.ctrlKey)
				char += "+CTRL";
			
			if (ke.altKey)
				char += "+ALT";
			
			if (ke.shiftKey)
				char += "+SHIFT";
			
			if (ke.commandKey)
				char += "+COMMAND";
		
			trace(char);
			_callback(char);
		}
						
		private function onGesture(ge:GestureEvent):void
		{
			trace("tap", ge.target, TapGesture(ge.currentTarget).location.x);
		}
			
		private function translateTapRequest(me:MouseEvent):String
		{
			var third:int;
			
			third = StageRef.stage.stageWidth / 3;

			if (me.stageX < third)
			{
				return "0";
			}
			else if (me.stageX > third * 2)
			{
				return "1";
			}
			else
				return "2";
		}			
		
	}
}