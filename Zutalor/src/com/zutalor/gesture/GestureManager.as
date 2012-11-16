package com.zutalor.gesture
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.application.AppRegistry;
	import com.zutalor.interfaces.IAcceptsGestureCallbacks;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.KeyUtils;
	import com.zutalor.utils.ShowError;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.getQualifiedClassName;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.AbstractContinuousGesture;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class GestureManager extends EventDispatcher implements IDisposable 
	{		
		private var _activeGestures:gDictionary;
		
		public function GestureManager()
		{
			_activeGestures = new gDictionary();
		}
				
		public function activateGesture(type:String, target:DisplayObject):void 
		{
			var gp:GestureProperties;
			var gestureClass:Class;
			
			gp = new GestureProperties();
			gp.target = target;
				
			gestureClass = AppRegistry.gestures.retrieve(type);
			
			if (!gestureClass)
				ShowError.fail(GestureManager, "Gesture type not registered: " + type);
			
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
		
		public function deactivateGesture(target:DisplayObject, type:String):void
		{
			removeListeners(_activeGestures.getByKey(target).getByKey(type));
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
		
		// PRIVATE METHODS	
		
		private function addToActiveGestures(gp:GestureProperties):void
		{	
			if (!_activeGestures.getByKey(gp.target))
				_activeGestures.insert(gp.target, new gDictionary());
			
			_activeGestures.getByKey(gp.target).insert(gp.type, gp);
		}
		
		private function removeListeners(gp:GestureProperties):void
		{
			
			if (gp)
			{
				for (var i:int = 0; i < gp.eventTypes.length; i++)
					gp.gesture.removeEventListener(gp.eventTypes[i], onGesture);
				
				gDictionary(_activeGestures.getByIndex(gp.target)).deleteByKey(gp.type);
				gp.dispose();
				gp = null;
			}
		}
		
		private function onGesture(ge:GestureEvent):void
		{
			dispatchEvent(ge.clone());
		}
	}
}