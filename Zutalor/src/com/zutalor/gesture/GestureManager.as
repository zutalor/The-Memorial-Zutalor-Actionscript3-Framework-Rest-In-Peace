package com.zutalor.gesture
{
	import com.zutalor.utils.KeyUtils;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
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
	 * @author Geoff Pepos
	 */
	public class GestureManager
	{
		public static const NOT_FOUND:int = -1;
		public static const SWIPE:String = "swipe";
		public static const PAN:String = "pan";
		
		private var _activeGestures:Dictionary;
		
		public function addCallback(target:*, type:String, callback:Function):void 
		{
			// target could use an interface to force compile time errors for methods expected on target.
			
			var gp:GestureProperties;
			
			gp = new GestureProperties(); // could use an object pool for this...but, it's only a few bytes.
			
			if (type.indexOf(SWIPE) != NOT_FOUND)
				activateGesture(SwipeGesture, false, { direction: GestureUtils.getSwipeDirection(type) } );
			else if (type.indexOf(PAN) != NOT_FOUND)
				activateGesture(PanGesture, false, { maxNumTouchesRequired: 2, direction: GestureUtils.getPanDirection(type) } );
			else 
			{
				switch (type)
				{
					case GestureTypes.KEY_PRESS: 
						gp.gestureId = GestureTypes.KEY_PRESS;
						gp.gesture = onKey;
						gp.callback = callback;
						gp.type = type;
						gp.target = target;
						gp.target.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
						gp.eventTypes.push(KeyboardEvent.KEY_UP);
						addToActiveGestures(gp);
						break;
					case GestureTypes.TAP: 
						activateGesture(TapGesture, true);
						break;
					case GestureTypes.DOUBLE_TAP: 
						activateGesture(DoubleTapGesture, true);
						break;
					case GestureTypes.LONG_PRESS: 
						activateGesture(LongPressGesture);
						break;
					case GestureTypes.ROTATE: 
						activateGesture(RotateGesture);
						break;
					case GestureTypes.TRANSFORM: 
						activateGesture(TransformGesture);
						break;
					case GestureTypes.ZOOM: 
						activateGesture(ZoomGesture);
						break;
				}
			}
			
			function activateGesture(gestureClass:Class, discrete:Boolean = false, vars:Object = null):void
			{
				gp.gestureId = getQualifiedClassName(gestureClass);
				gp.gesture = new gestureClass(target);
				gp.callback = callback;
				gp.target = target;
				gp.type = type;
				
				if (vars)
					for (var setting:* in vars)
						gp.gesture[setting] = vars[setting];
								//this could cause errors, except it's controlled inside this class.
				
				if (!discrete) // meaning the default; it's a continuous gesture like most of them.
				{
					gp.eventTypes.push(GestureEvent.GESTURE_BEGAN);
					gp.eventTypes.push(GestureEvent.GESTURE_CHANGED);
				}
				else
					gp.eventTypes.push(GestureEvent.GESTURE_RECOGNIZED);
				
				for (var i:int = 0; i < gp.eventTypes.length; i++)
					gp.gesture.addEventListener(gp.eventTypes[i], onGesture); 
				
				addToActiveGestures(gp);
			}
		}
		
		public function removeCallback(target:*, type:String, callback:Function):void
		{
			removeListeners(_activeGestures[target][getGestureId(type)]);
		}
		
		public function dispose():void
		{
			for (var target:Object in _activeGestures)
			{
				for (var gestureId:Object in _activeGestures[target])
				{
					removeListeners(_activeGestures[target][gestureId]);
					_activeGestures[target][gestureId] = null;
				}
				_activeGestures[target] = null;
			}
			_activeGestures = null; // could recyle yet not too hard on the garbage collector.
		}
		
		// private methods	
		
		private function addToActiveGestures(gp:GestureProperties):void
		{
			if (!_activeGestures)
				_activeGestures = new Dictionary;
			
			if (!_activeGestures[gp.target])
				_activeGestures[gp.target] = new Dictionary();
			
			_activeGestures[gp.target][gp.gestureId] = gp;
		}
		
		private function removeListeners(gp:GestureProperties):void
		{
			if (gp)
			{
				if (gp.gestureId == GestureTypes.KEY_PRESS)
					gp.target.removeEventListener(gp.eventTypes[0], onKey);
				else
					for (var i:int = 0; i < gp.eventTypes.length; i++)
						gp.gesture.removeEventListener(gp.eventTypes[i], onGesture);
				
				// next: we could recycle the gp object...but why?
				// it's only a few bytes! Garbage collector won't work hard.
				
				gp.gesture.dispose();
				gp.eventTypes = null;
				gp.result.location = null;
				gp.target = null;
				gp.callback = null;
				gp.result = null;
				
				gp.gesture = null;
				_activeGestures[gp.target][gp.gestureId] = null;
				gp.gestureId = null;
				gp = null;
			}
		}
		
		private function onKey(ke:KeyboardEvent):void
		{
			var char:String;
			var gp:GestureProperties;
			
			char = KeyUtils.shortCutForKeyCode(ke.keyCode);
			if (char == null)
				char = String.fromCharCode(ke.charCode);
			
			if (ke.ctrlKey)
				char += KeyUtils.CONTROL;
			
			if (ke.altKey)
				char += KeyUtils.ALT;
			
			if (ke.shiftKey)
				char += KeyUtils.SHIFT;
			
			if (ke.commandKey)
				char += KeyUtils.COMMAND;
			
			gp = _activeGestures[ke.currentTarget][GestureTypes.KEY_PRESS];
			gp.result.value = char;
			gp.callback(gp);
		}
		
		private function onGesture(ge:GestureEvent):void
		{
			var gp:GestureProperties;
			
			gp = _activeGestures[ge.target.target][getQualifiedClassName(ge.target)];
			gp.result.value = gp.type;
			
			if (gp.type.indexOf(PAN) != NOT_FOUND || gp.type.indexOf(SWIPE) != NOT_FOUND) // a couple double negatives
			{
				gp.result.offsetX = gp.target.offsetX = ge.currentTarget.offsetX;
				gp.result.offsetY = gp.target.offsetY = ge.currentTarget.offsetY;
			}
			else
			{
				switch (gp.type)
				{
					case GestureTypes.TAP: 
					case GestureTypes.DOUBLE_TAP: 
					case GestureTypes.LONG_PRESS: 
						gp.result.location.x = ge.currentTarget.location.x;
						gp.result.location.y = ge.currentTarget.location.y;
						break;
					case GestureTypes.ROTATE: 
						gp.result.rotation = gp.target.rotation = ge.currentTarget.rotation;
						break;	
					case GestureTypes.TRANSFORM: 
						gp.result.rotation = gp.target.rotation = ge.currentTarget.rotation;
						gp.result.scaleX = gp.target.scaleX = ge.currentTarget.scale;
						gp.result.scaleY = gp.target.scaleY = ge.currentTarget.scale;
						break;
					case GestureTypes.ZOOM: 
						gp.result.scaleX = gp.result.scaleY = ge.currentTarget.scaleX;
						gp.result.scaleY = gp.result.scaleY = ge.currentTarget.scaleY;
						gp.target.scaleX = gp.result.scaleX;
						gp.target.scaleY = gp.result.scaleY;
						break;
					default: 
						break;
				}
			}
			gp.callback(gp);
		}
		
		private function getGestureId(type:String):String
		{
			var gesture:Class;
			
			if (type.indexOf(PAN) != NOT_FOUND)
				gesture = PanGesture;
			else if (type.indexOf(SWIPE) != NOT_FOUND)
				gesture = SwipeGesture;
			else
			{
				switch (type)
				{
					case GestureTypes.TAP: 
						gesture = TapGesture;
						break;
					case GestureTypes.DOUBLE_TAP: 
						gesture = DoubleTapGesture;
						break;
					case GestureTypes.LONG_PRESS: 
						gesture = LongPressGesture;
						break;
					case GestureTypes.ROTATE: 
						gesture = RotateGesture;
						break;
					case GestureTypes.TRANSFORM: 
						gesture = TransformGesture;
						break;
					case GestureTypes.ZOOM: 
						gesture = ZoomGesture;
						break;
				}
			}
			return getQualifiedClassName(gesture);
		}
	}
}