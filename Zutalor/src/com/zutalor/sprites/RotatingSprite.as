package com.zutalor.sprites 
{
	import com.zutalor.utils.TimerRegistery;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class RotatingSprite extends AnimationSprite
	{
		private var _speed:Number;
		private var _degrees:Number = 0;
		private var _rotation:Number;
		private var _timerMs:uint;
		
		private var _do :DisplayObject;
		public var point:Point = new Point();		

		
		public function RotatingSprite(displayObject:DisplayObject = null, speed:Number = 5, timerMs:uint = 20)
		{
			if (displayObject)
			{
				_speed = speed;
				_timerMs = timerMs;
				addChild(displayObject);
				_do = displayObject;
				
				point.x = (_do .x + _do .width) >> 1;
				point.y = (_do .y + _do .height) >> 1;
			}
		}
				
		override public function start():void
		{
			MasterClock.registerCallback(rotate, true, _timerMs) 
		}
		
		override public function stop():void
		{
			MasterClock.unRegisterCallback(rotate);
		}
		
		private function rotate():void
		{			
			var m:Matrix = _do.transform.matrix;
			
			m.tx -= point.x;
			m.ty -= point.y;
			m.rotate(_speed / 180 * Math.PI);
			
			m.tx += point.x;
			m.ty += point.y;

			_do.transform.matrix = m;

		}
	}
}