package com.zutalor.gesture 
{
	import com.adobe.xml.syndication.atom.Generator;
	import com.zutalor.utils.GetShortCut;
	import com.zutalor.utils.StageRef;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
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
				
		public function GestureManager() 
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
			var gp:GestureProperties;
			
			gp = new GestureProperties();
			
			switch (type)
			{
				case KEY_PRESS :
					gp.gesture = onKey;
					gp.gestureId = onKey;
					gp.callback = callback;
					gp.target = StageRef.stage;
					gp.target.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
					gp.listeners.push(KeyboardEvent.KEY_DOWN);
					gp.listeners.push(KeyboardEvent.KEY_UP);
					addToDict(gp);
					break;
				case TAP :
				case DOUBLE_TAP :
					gp.gesture = new TapGesture(target);
					gp.gestureId = TapGesture; 
					gp.target = target;
					gp.callback = callback;
					if (type == DOUBLE_TAP)
					{
						gp.gesture.numTapsRequired = 2;
						gp.gesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onGesture, false, 0, true)
					}
					else
					{
						gp.gesture.numTapsRequired = 1;
						gp.gesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onGesture, false, 0, true)
					}	
					gp.listeners.push(GestureEvent.GESTURE_RECOGNIZED);
					addToDict(gp);
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
			function addGestureListener(gesture:Class):void
			{
				gp.callback = callback;
				gp.gesture = new gesture(target);
				gp.gestureId = gesture;
				gp.target = target;
				gp.gesture.addEventListener(GestureEvent.GESTURE_BEGAN, onGesture);
				gp.gesture.addEventListener(GestureEvent.GESTURE_CHANGED, onGesture);
				gp.listeners.push(GestureEvent.GESTURE_BEGAN);
				gp.listeners.push(GestureEvent.GESTURE_CHANGED);		
				addToDict(gp);	
			}
		}
		
		// private methods	
		
		private function addToDict(gp:GestureProperties):void
		{
			if (!_dict)
				_dict = new Dictionary;
			
			if (!_dict[gp.target])
				_dict[gp.target] = new Dictionary();

			if (!_dict[gp.target][gp.gestureId])
				_dict[gp.target][gp.gestureId] = new Dictionary;
			
			removeListeners(_dict[gp.target][gp.gestureId][gp.callback]); // just in case
			_dict[gp.target][gp.gestureId][gp.callback] = gp;
		}
		
		private function removeListeners(gp:GestureProperties):void
		{
			if (gp)
			{
				if (gp.gesture is Function)
					gp.target.removeEventListener(gp.listeners[0], onKey);
				else
				{
					for (var i:int = 0; i < gp.listeners.length; i++)
					{
						gp.gesture.removeEventListener(gp.listeners[i], onGesture);
						gp.gesture.dispose();
					}
				}
				gp.listeners = [];
				_dict[gp.target][gp.gestureId][gp.callback] = null;
			}
		}
		
		private function onKey(ke:KeyboardEvent):void
		{
			var char:String;
			var gp:GestureProperties;
			
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
			gp = _dict[ke.currentTarget][onKey];
			
			if (gp && gp.callback)
				gp.callback(char);
			else
				trace("GestureManager Error:", gp);
		}
						
		private function onGesture(ge:GestureEvent):void
		{
			switch (Class(getDefinitionByName(getQualifiedClassName(ge.target))))
			{
				case TapGesture :
					trace("tap", ge.target, TapGesture(ge.currentTarget).location.x);
					break;
				default :
					break;
			}
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