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
	public class GestureListener extends EventDispatcher implements IDisposable 
	{		
		private var _activeGestures:gDictionary;
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
		
		public function GestureListener()
		{
			_activeGestures = new gDictionary();
			addEventListener(AppGestureEvent.RECOGNIZED, onGesture);
		}
					
		public function activateGesture(type:String, target:DisplayObject, listener:Function):void 
		{
			var agp:ActiveGestureProperties;
			var gestureClass:Class;
			var qualifiedClassName:String;
			var targetDictionary:gDictionary;

			gestureClass = _gestureClasses.getByKey(type);
			if (!gestureClass)
				ShowError.fail(GestureListener, "Gesture type not registered: " + type);
			
			qualifiedClassName = getQualifiedClassName(gestureClass);
			targetDictionary = _activeGestures.getByKey(target);
			
			if (targetDictionary)
				agp = targetDictionary.getByKey(qualifiedClassName);
			
			if (agp)
				removeActiveGesture(agp);
				
			agp = new ActiveGestureProperties();
			agp.type = type;
			agp.target = target;
			agp.listener = listener;
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
			return GestureListener;
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
			var age:AppGestureEvent;
			agp = gDictionary(_activeGestures.getByKey(ge.target.target)).getByKey(getQualifiedClassName(ge.target));
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