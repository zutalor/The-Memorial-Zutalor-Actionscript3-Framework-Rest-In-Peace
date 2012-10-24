package com.zutalor.utils 
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MatrixUtils 
	{

		public static function rotateAroundCenter(obj:DisplayObject, angleDegrees:Number):void
		{
			var ptRotationPoint:Point;
			
			ptRotationPoint = new Point(obj.x + obj.width/2, obj.y+obj.height/2);
			
			var m:Matrix = obj.transform.matrix;
			
			m.tx -= ptRotationPoint.x;
			m.ty -= ptRotationPoint.y;
			m.rotate (angleDegrees*(Math.PI/180));
			m.tx += ptRotationPoint.x;
			m.ty += ptRotationPoint.y;
			obj.transform.matrix=m;
		}
	}
}