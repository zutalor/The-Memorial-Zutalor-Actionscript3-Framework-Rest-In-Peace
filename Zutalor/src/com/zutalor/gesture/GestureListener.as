package com.zutalor.gesture
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.ShowError;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.AbstractContinuousGesture;
	import org.gestouch.gestures.Gesture;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 * This class only allows one listener per event type.
	 * 
	 */
	public class GestureListener extends EventDispatcher implements IDisposable 
	{		
		private var _activeGestures:gDictionary;
		private var _target:ContainerObject;
		
		private static var _gestureClasses:gDictionary;
		
		public static function register(Klass:Class, name:String = null):String
		{
			var className:String;
			
			if (!_gestureClasses)
				_gestureClasses = new gDictionary();
			
			if (name)
				className = name;
			else
				className = getClassName(Klass);		
			
			_gestureClasses.insert(className, Klass);
			return className;
		}
		
		public function GestureListener(target:ContainerObject)
		{
			_target = target;
			_activeGestures = new gDictionary();
			addEventListener(AppGestureEvent.RECOGNIZED, onGesture);
		}
					
		public function activateGesture(type:String, listener:Function):void 
		{
			var agp:ActiveGestureProperties;
			var gestureClass:Class;
			
			gestureClass = _gestureClasses.getByKey(type);
			if (!gestureClass)
				ShowError.fail(GestureListener, "Gesture type not registered: " + type);
			
			agp = _activeGestures.getByKey(gestureClass);
			
			if (agp)
				removeActiveGesture(agp);
		
			agp = new ActiveGestureProperties();
			agp.type = type;
			agp.listener = listener;
			agp.gesture = new gestureClass(_target);
			
			if (agp.gesture is AbstractContinuousGesture)
			{
				agp.eventTypes.push(GestureEvent.GESTURE_BEGAN);
				agp.eventTypes.push(GestureEvent.GESTURE_CHANGED);
			}
			else
				agp.eventTypes.push(GestureEvent.GESTURE_RECOGNIZED);
			
			for (var i:int = 0; i < agp.eventTypes.length; i++)
				agp.gesture.addEventListener(agp.eventTypes[i], onGesture); 
			
			_activeGestures.insert(type, agp);
		}
		
		public function deactivateGesture(type:String):void
		{
			removeActiveGesture(_activeGestures.getByKey(type));
		}
		
		public function deactivateAllGestures():void
		{
			var l:int;
		
			l = _activeGestures.length;
			for (var i:int = 0; i < l; i++)
				removeActiveGesture(_activeGestures.getByIndex(i));
		}
		
		public function dispose():void
		{
			removeEventListener(AppGestureEvent.RECOGNIZED, onGesture);
			deactivateAllGestures();
			_activeGestures.dispose();
			_activeGestures = null; 
		}
		
		public function reflect():Class
		{
			return GestureListener;
		}
		
		// PRIVATE METHODS	
		
		private function removeActiveGesture(agp:ActiveGestureProperties):void
		{
			if (agp)
			{
				for (var i:int = 0; i < agp.eventTypes.length; i++)
					agp.gesture.removeEventListener(agp.eventTypes[i], onGesture);
				
				_activeGestures.deleteByKey(agp.type);
				agp.dispose();
			}
		}
		
		private function onGesture(ge:GestureEvent):void
		{
			var agp:ActiveGestureProperties;
			var age:AppGestureEvent;
			var className:String;
			
			className = getClassName(ge.target.reflect());
			agp = _activeGestures.getByKey(className);
			age = new AppGestureEvent(agp.type, Gesture(ge.target));
			agp.listener(age);
		}
		
		private static function getClassName(Klass:Class):String
		{
			var p:int;
			var fullClassName:String;

			fullClassName = getQualifiedClassName(Klass);		
			
			p = fullClassName.indexOf("::");
			
			if (p > 0)
				return fullClassName.slice(p + 2); 
			else
				return fullClassName;
		}
	}
}