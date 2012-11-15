﻿package com.zutalor.containers
{	
	import com.zutalor.sprites.CenterSprite;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Container extends CenterSprite
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
		
		private var _name:String;
		
		public function Container()
		{
			posOffsetX = 0;
			posOffsetY = 0;
			savedScale = 0;
			mass = 0;
			friction = 0;
			windAffect = 0;
		}	
		
		override public function set name(name:String):void
		{
			_name = name;
		}
		
		override public function get name():String
		{
			return _name;
		}
	}
}