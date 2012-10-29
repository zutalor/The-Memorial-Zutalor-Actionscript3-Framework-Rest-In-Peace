package com.zutalor.input 
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
	public class InputManager
	{		
		public static const LONG_PRESS:String = "longpress";
		public static const PAN:String = "pan";
		public static const ROTATE:String = "rotate";
		public static const SWIPE:String = "swipe";
		public static const TRANSFORM:String = "transform";
		public static const ZOOM:String = "zoom";
		public static const TAP:String = "tap";
		public static const DOUBLE_TAP:String = "doubletap";
		public static const KEY_DOWN:String = "keydown";
		public static const KEY_UP:String = "keyup";
		
		private var _dict:Dictionary;
		private var _target:*;
		private var _gesture:*;
		private var _callback:Function;
		
		public function InputManager() 
		{
			init();
		}
		
		public function dispose():void
		{
			//TODO
		}
				
		// private methods

		private function init():void
		{
			_dict = new Dictionary;
		}
		
		public function add(target:*, type:String, callback:Function):void
		{
			var ip:InputProperties;
			
			_target = target;
			_callback = callback;

			switch (type)
			{
				case KEY_DOWN :
					ip = new InputProperties();
					ip.gesture = ip.callback = onKey;
					ip.target = StageRef.stage;
					ip.target.addEventListener(KeyboardEvent.KEY_DOWN, onKey, false, 0, true);
					ip.listeners.push(KeyboardEvent.KEY_DOWN);
					addToDict(ip);
					break;
				case KEY_UP :
					ip = new InputProperties();
					ip.gesture = ip.callback = onKey;
					ip.target = StageRef.stage;
					ip.target.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
					ip.listeners.push(KeyboardEvent.KEY_UP);
					addToDict(ip);
					break;
				case TAP :
				case DOUBLE_TAP :
					ip = new InputProperties();
					ip.gesture = new TapGesture(_target);
					ip.target = _target;
					if (type == DOUBLE_TAP)
					{
						ip.callback = onDoubleTap;
						ip.gesture.numTapsRequired = 2;
					}
					else
					{
						ip.callback = onTap;
						ip.gesture.numTapsRequired = 1;
					}	
					ip.gesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onDoubleTap, false, 0, true);
					ip.listeners.push(GestureEvent.GESTURE_RECOGNIZED);
					addToDict(ip);
					break;
				case LONG_PRESS :
					addGestureListener(LongPressGesture, onLongPress);
					break;
				case PAN :
					addGestureListener(PanGesture, onPan);
					break;
				case ROTATE :
					addGestureListener(RotateGesture, onRotate);
					break;
				case SWIPE :
					addGestureListener(SwipeGesture, onSwipe);
					break;
				case TRANSFORM :
					addGestureListener(TransformGesture, onTransform);
					break;
				case ZOOM :
					addGestureListener(ZoomGesture, onZoom);
					break;				
			}
		}
		
		private function addGestureListener(gesture:Class, gestureCallBack:Function):void
		{
			var oldIp:InputProperties;
			var ip:InputProperties;
			
			ip = new InputProperties;
			ip.callback = _callback;
			ip.gesture = new gesture(_target);
			ip.target = _target;
			ip.gesture.addEventListener(GestureEvent.GESTURE_BEGAN, gestureCallBack);
			ip.gesture.addEventListener(GestureEvent.GESTURE_CHANGED, gestureCallBack);
			ip.listeners.push(GestureEvent.GESTURE_BEGAN);
			ip.listeners.push(GestureEvent.GESTURE_CHANGED);

			oldIp =  _dict[_target][gesture];
			
			if (oldIp)
				removeListener(oldIp);
		
			addToDict(ip);	
		}
		
		private function addToDict(ip:InputProperties):void
		{
			if(!_dict[ip.target])
				_dict[ip.target] = new Dictionary();

			_dict[ip.target][ip.gesture] = ip;
		}
		
		private function removeListener(oldIp:InputProperties):void
		{
			//TODO
		}
		
		private function onLongPress(ge:GestureEvent):void
		{
			trace("long press");
		}
		
		private function onPan(ge:GestureEvent):void
		{
			trace("Pan");
		}
		
		private function onRotate(ge:GestureEvent):void
		{
			trace("Rotate");
		}
		
		private function onSwipe(ge:GestureEvent):void
		{
			trace("onSwipe");
		}
		
		private function onTransform(ge:GestureEvent):void
		{
			trace("Transform");
		}
		
		private function onZoom(ge:GestureEvent):void
		{
			trace("Zoom");
		}
		
		private function onKey(ke:KeyboardEvent):void
		{
			var char:String
			
			char = GetShortCut.forKey(ke.keyCode);
			if (char == null) 
				char=String.fromCharCode(ke.charCode);
			trace(char);
			_callback(char);
		}

		private function onDoubleTap(ge:GestureEvent):void
		{
			trace("doubleTap");
		}
		
		private function onTap(me:MouseEvent):void
		{
			_callback(translateTapRequest(me));
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