package com.zutalor.gesture
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.ShowError;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.AbstractContinuousGesture;
	import org.gestouch.gestures.Gesture;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class GestureMediator extends EventDispatcher implements IDisposable 
	{		
		private static var _activeGestures:gDictionary;
		private static var _plugins:*;
		private static var _instance:*;
		
		public static function initialize(plugins:*):void
		{
			if (!_instance)
			{
				_activeGestures = new gDictionary();
				_plugins = plugins;
				_instance = new GestureMediator();
			}
		}
		
		public static function gi():GestureMediator
		{	
			if (!_instance)
				ShowError.fail(GestureMediator, "Must be initialiazed first.");

			return _instance;
		}
		
				
		public function activateGesture(type:String, target:DisplayObject, name:String):void 
		{
			var agp:ActiveGestureProperties;
			var gestureClass:Class;
			var qualifiedClassName:String;
			var targetDictionary:gDictionary;

			gestureClass = _plugins.getClass(type);
			if (!gestureClass)
				ShowError.fail(GestureMediator, "Gesture type not registered: " + type);
			
			qualifiedClassName = getQualifiedClassName(gestureClass);
			targetDictionary = _activeGestures.getByKey(target);
			if (targetDictionary)
				agp = targetDictionary.getByKey(qualifiedClassName);
			
			if (agp)
				removeActiveGesture(agp);
				
			agp = new ActiveGestureProperties();
			agp.target = target;
			agp.name = name;
			agp.qualifiedClassName = qualifiedClassName;
			agp.gesture = new gestureClass(target);
			
			if (agp.gesture is AbstractContinuousGesture)
			{
				agp.eventTypes.push(GestureEvent.GESTURE_BEGAN);
				agp.eventTypes.push(GestureEvent.GESTURE_CHANGED);
			}
			else
				agp.eventTypes.push(GestureEvent.GESTURE_RECOGNIZED);
			
			for (var i:int = 0; i < agp.eventTypes.length; i++)
				agp.gesture.addEventListener(agp.eventTypes[i], onGesture); 
			
			addToActiveGestures(agp);
		}
		
		public function deactivateGesture(target:DisplayObject, gesture:Gesture):void
		{
			removeActiveGesture(_activeGestures.getByKey(target).getByKey(getQualifiedClassName(gesture)));
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
				for (var i2:int = 0; i2 < l2; i2++)
				{
					removeActiveGesture(ActiveGestureProperties(d.getByIndex(i2)));
					d.deleteByIndex(i2);
				}
				d.dispose();
			}
			_activeGestures.dispose();
			_activeGestures = null; 
		}
		
		public function reflect():Class
		{
			return GestureMediator;
		}
		
		// PRIVATE METHODS	
		
		private function addToActiveGestures(agp:ActiveGestureProperties):void
		{	
			var targetDictionary:gDictionary;
			
			targetDictionary = _activeGestures.getByKey(agp.target);
			
			if (!targetDictionary)
				targetDictionary = _activeGestures.insert(agp.target, new gDictionary());
			
			targetDictionary.insert(agp.qualifiedClassName, agp);
		}
		
		private function removeActiveGesture(agp:ActiveGestureProperties):void
		{
			if (agp)
			{
				for (var i:int = 0; i < agp.eventTypes.length; i++)
					agp.gesture.removeEventListener(agp.eventTypes[i], onGesture);
				
				gDictionary(_activeGestures.getByIndex(agp.target)).deleteByKey(agp.qualifiedClassName);
				agp.dispose();
			}
		}
		
		private function onGesture(ge:GestureEvent):void
		{
			var agp:ActiveGestureProperties;
			agp = gDictionary(_activeGestures.getByKey(ge.target.target)).getByKey(getQualifiedClassName(ge.target));
			dispatchEvent(new AppGestureEvent(AppGestureEvent.RECOGNIZED, Gesture(ge.target), agp.name));
		}
	}
}