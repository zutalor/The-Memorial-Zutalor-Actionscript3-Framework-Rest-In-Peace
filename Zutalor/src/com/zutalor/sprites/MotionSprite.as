package com.zutalor.sprites
{	
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MotionSprite extends CenterSprite
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
		
		public var xOffset:Number;
		public var yOffset:Number;
		public var savedScale:Number;
		
		public function MotionSprite()
		{
			xOffset = 0;
			yOffset = 0;
			savedScale = 0;
			mass = 0;
			friction = 0;
			windAffect = 0;
		}		
	}
}