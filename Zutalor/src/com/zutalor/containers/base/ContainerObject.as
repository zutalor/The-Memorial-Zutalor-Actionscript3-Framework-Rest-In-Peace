package com.zutalor.containers.base
{	
	import com.zutalor.gesture.AppGestureEvent;
	import com.zutalor.gesture.GestureListener;
	import com.zutalor.interfaces.IContainerObject;
	import flash.events.Event;
	/**
	 * 
	 * @author Geoff Pepos
	 */
	public class ContainerObject extends CenterSprite implements IContainerObject
	{
		public var vx:Number;
		public var vy:Number;
		public var vz:Number;
	
		public var rotvx:Number;
		public var rotvy:Number;
		
		public var mass:Number;
		public var friction:Number;
		public var springLength:Number
		public var spring:Number;
		public var windAffect:Number;

		public var dragType:String;
		public var dragging:Boolean;
		public var inMotion:Boolean;
		
		public var savedX:Number;
		public var savedY:Number;
		
		public var posOffsetX:Number;
		public var posOffsetY:Number;
		public var savedScale:Number;
		
		private var _editable:Boolean;
		private var _enabled:Boolean;
		private var _gestureListener:GestureListener;
		
		public function ContainerObject()
		{
			posOffsetX = 0;
			posOffsetY = 0;
			savedScale = 0;
			mass = 0;
			friction = 0;
			windAffect = 0;
			editable = false;
		}
		
		public function addGestureListener(type:String, listener:Function):void
		{
			if (!_gestureListener)
				_gestureListener = new GestureListener();
	
			_gestureListener.activateGesture(type, this, listener);
		}
		
		public function set editable(value:Boolean):void
		{
			_editable = value;
		}
		
		public function get editable():Boolean
		{
			return _editable;
		}
	
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function dispose():void {}
		public function recycle():void {}
		public function stop(fadeSeconds:Number = 0):void {}	
	}
}