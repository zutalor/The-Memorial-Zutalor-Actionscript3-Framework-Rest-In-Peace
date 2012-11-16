package com.zutalor.gesture
{
	import com.zutalor.application.AppRegistry;
	import com.zutalor.interfaces.IAcceptsGestureCallbacks;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.KeyUtils;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.utils.getQualifiedClassName;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.AbstractContinuousGesture;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class GestureManager
	{		
		private var _activeGestures:gDictionary;
		
		public function GestureManager()
		{
			_activeGestures = new gDictionary();
		}
				
		public function addCallback(target:DisplayObject, name:String, type:String, caller:IAcceptsGestureCallbacks):void 
		{
			var gp:GestureProperties;
			
			gp = new GestureProperties();
			gp.target = target;
			gp.type = type;
			gp.name = name;
			gp.type = type;
			gp.caller = caller;
				
			if (type == GestureTypes.KEY_PRESS)
			{
				gp.gestureQualifiedClassName = GestureTypes.KEY_PRESS;
				gp.gesture = onKey;
				gp.target.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
				gp.eventTypes.push(KeyboardEvent.KEY_UP);
				addToActiveGestures(gp);
			}
			else
				activateGesture(AppRegistry.gestures.retrieve(type));
			
			function activateGesture(gestureClass:Class):void
			{
				gp.gestureQualifiedClassName = getQualifiedClassName(gestureClass);
				gp.gesture = new gestureClass(target);
				
				if (gp.gesture is AbstractContinuousGesture)
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
			removeListeners(_activeGestures.getByKey(target).getByKey(getGestureClassName(type)));
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
		}
		
		// private methods	
		
		private function addToActiveGestures(gp:GestureProperties):void
		{	
			if (!_activeGestures.getByKey(gp.target))
				_activeGestures.insert(gp.target, new gDictionary());
			
			_activeGestures.getByKey(gp.target).insert(gp.gestureQualifiedClassName, gp);
		}
		
		private function removeListeners(gp:GestureProperties):void
		{
			
			if (gp)
			{
				if (gp.gestureQualifiedClassName == GestureTypes.KEY_PRESS)
					gp.target.removeEventListener(gp.eventTypes[0], onKey);
				else
					for (var i:int = 0; i < gp.eventTypes.length; i++)
						gp.gesture.removeEventListener(gp.eventTypes[i], onGesture);
				
				gDictionary(_activeGestures.getByIndex(gp.target)).deleteByKey(gp.gestureQualifiedClassName);
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
			gp.keyPressed = char;
			gp.caller.onGesture(gp);
		}
		
		private function onGesture(ge:GestureEvent):void
		{
			var gp:GestureProperties;
			/*
			if (!isNaN(ge.target.offsetX))
				gp.result.offsetX = gp.target.offsetX = ge.currentTarget.offsetX;
			
			if (!isNaN(ge.currentTarget.offsetY))
				gp.result.offsetY = gp.target.offsetY = ge.currentTarget.offsetY;
			
			/*
			
				gp.result.offsetY = gp.target.offsetY = ge.currentTarget.offsetY;
				gp.result.location.x = ge.currentTarget.location.x;
				gp.result.location.y = ge.currentTarget.location.y;
				
				
				gp.result.scaleX = gp.target.scaleX = ge.currentTarget.scale;
				gp.result.scaleY = gp.target.scaleY = ge.currentTarget.scale;

				gp.result.scaleX = gp.result.scaleY = ge.currentTarget.scaleX;
				gp.result.scaleY = gp.result.scaleY = ge.currentTarget.scaleY;
				gp.target.scaleX = gp.result.scaleX;
				gp.target.scaleY = gp.result.scaleY;
				
			*/
				gp = gDictionary(_activeGestures.getByKey(ge.target.target)).getByKey(getQualifiedClassName(ge.target));
				gp.gestureEvent = ge;
				gp.caller.onGesture(gp);
		}
		
		private function getGestureClassName(type:String):String
		{
			var gesture:Class;
			
			gesture = AppRegistry.gestures.retrieve(type)
			return getQualifiedClassName(gesture);
		}
	}
}