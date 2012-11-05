package com.zutalor.gesture
{
	import com.zutalor.interfaces.IAcceptsGestureCallbacks;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.KeyUtils;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
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
		
		private var _activeGestures:gDictionary;
		private var _gestures:gDictionary;
		
		public function GestureManager()
		{
			initGestureDictionary();
		}
				
		public function addCallback(target:*, type:String, caller:IAcceptsGestureCallbacks):void 
		{
			var gp:GestureProperties;
			gp = new GestureProperties();
			
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
						gp.caller = caller;
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
				gp.caller = caller;
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
		
		public function removeCallback(target:*, type:String):void
		{
			removeListeners(_activeGestures.getByKey(target).getByKey(getGestureId(type)));
		}
		
		public function dispose():void
		{
			var d:gDictionary;
			var l:int;
			var l2:int;
			
			l = _activeGestures.length;
			for (var i:int = 0; i < l; i++)
			{
				d = gDictionary(_activeGestures.getByIndex(i));
				l2 = d.length;
				for (var ii:int = 0; ii < l2; ii++)
				{
					removeListeners(GestureProperties(d.getByIndex(ii)));
					d.deleteByIndex(ii);
				}
				d.dispose();
			}
			_activeGestures.dispose();
			_activeGestures = null; 
			_gestures.dispose();
			_gestures = null;
		}
		
		// private methods	
		
		private function addToActiveGestures(gp:GestureProperties):void
		{
			if (!_activeGestures)
				_activeGestures = new gDictionary;
			
			if (!_activeGestures.getByKey(gp.target))
				_activeGestures.insert(gp.target, new gDictionary());
			
			_activeGestures.getByKey(gp.target).insert(gp.gestureId, gp);
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
				
				gDictionary(_activeGestures.getByIndex(gp.target)).deleteByKey(gp.gestureId);
				gp.dispose();
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
				char += "+" + KeyUtils.CONTROL;
			
			if (ke.altKey)
				char += "+" + KeyUtils.ALT;
			
			if (ke.shiftKey)
				char += "+" + KeyUtils.SHIFT;
			
			if (ke.commandKey)
				char += "+" + KeyUtils.COMMAND;
			
			gp = gDictionary(_activeGestures.getByKey(ke.currentTarget)).getByKey(GestureTypes.KEY_PRESS);
			gp.result.value = char;
			gp.caller.onGesture(gp);		

		}
		
		private function onGesture(ge:GestureEvent):void
		{
			var gp:GestureProperties;
			
			gp = _activeGestures.getByKey(ge.target.target).getByKey(getQualifiedClassName(ge.target));
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
			gp.caller.onGesture(gp);

		}
		
		private function getGestureId(type:String):String
		{
			var gesture:Class;
			
			if (type.indexOf(PAN) != NOT_FOUND)
				gesture = PanGesture;
			else if (type.indexOf(SWIPE) != NOT_FOUND)
				gesture = SwipeGesture;
			else
				gesture = _gestures.getByKey(type);

			return getQualifiedClassName(gesture);
		}
		
		private function initGestureDictionary():void
		{
			_gestures = new gDictionary;
			_gestures.insert(GestureTypes.DOUBLE_TAP, DoubleTapGesture);
			_gestures.insert(GestureTypes.TAP, TapGesture);
			_gestures.insert(GestureTypes.LONG_PRESS, LongPressGesture);
			_gestures.insert(GestureTypes.ROTATE, RotateGesture);
			_gestures.insert(GestureTypes.TRANSFORM, TransformGesture);
			_gestures.insert(GestureTypes.ZOOM, ZoomGesture);
		}
	}
}