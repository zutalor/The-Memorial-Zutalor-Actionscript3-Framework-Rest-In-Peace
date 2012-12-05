package com.zutalor.containers.base 
{
	import com.zutalor.utils.Scale;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class CenterSprite extends Sprite
	{
		public var _rotation:Number = 0;
		public var _sx:Number;
		public var _sy:Number;
		public var _lastSx:Number = 1;
		public var _lastSy:Number = 1;
		private var _rotatePoint:Point;	
		private var _scalePoint:Point;	
		
		public function CenterSprite()
		{
			_sx = _sy = 1;
		}
				
		public function set rotationAroundCenter(r:Number):void
		{		
			rotateAroundCenter(r);
		}
		
		public function get rotationAroundCenter():Number
		{
			return _rotation;
		}
		
		private function rotateAroundCenter(angleDegrees:Number):void
		{
			var m:Matrix; 
			
			_rotatePoint = getCenter(); 
			
			m = this.transform.matrix;
			m.tx -= _rotatePoint.x;
			m.ty -= _rotatePoint.y;
			m.rotate ((angleDegrees - _rotation) * (Math.PI/180));
			m.tx += _rotatePoint.x;
			m.ty += _rotatePoint.y;
			this.transform.matrix = m;
			_rotation = angleDegrees;
		}
		
		public function scaleFromCenter(sx:Number, sy:Number):void
		{
 			var m:Matrix;
			
			_sx = sx;
			_sy = sy;

			_scalePoint = getCenter();

			m = this.transform.matrix;
			m.tx -= _scalePoint.x;
			m.ty -= _scalePoint.y;
			m.scale(sx * (1 / _lastSx), sy * (1 / _lastSy));
			m.tx += _scalePoint.x;
			m.ty += _scalePoint.y;
			this.transform.matrix = m;
			_lastSx = _sx;
			_lastSy = _sy;
		}
		
		public function get sx():Number
		{
			return _sx;
		}
		
		public function get sy():Number
		{
			return _sy;
		}
		
		public function set sx(n:Number):void
		{
			scaleFromCenter(n, _sy);
		}
		
		public function set sy(n:Number):void
		{
			scaleFromCenter(_sx, n);
		}
		
		private function getCenter():Point
		{
			
			return new Point(this.width / 2, this.height / 2);
		}
	}
}