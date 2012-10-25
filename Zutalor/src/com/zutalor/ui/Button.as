package com.zutalor.ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Button extends Sprite
	{
		private var _sb:SimpleButton;
		private var _up:DisplayObjectContainer;
		private var _over:DisplayObjectContainer;
		private var _down:DisplayObjectContainer;
		private var _disabled:DisplayObjectContainer;
		private var _selected:DisplayObjectContainer;
		private var _hit:DisplayObjectContainer;
				
		private var _name:String;
		
		public function create(up:DisplayObjectContainer, over:DisplayObjectContainer,
								down:DisplayObjectContainer, disabled:DisplayObjectContainer):void
		{
			_up = up;
			_disabled = disabled;
			_over = over;
			_down = down;
			_hit = down;
			_sb = new SimpleButton(up, over, down, _hit);		
			addChild(_sb);
		}
		
		public function get up():DisplayObjectContainer
		{
			return _up;
		}
		public function get over():DisplayObjectContainer
		{
			return _over;
		}
		public function get down():DisplayObjectContainer
		{
			return _down
		}
		public function get disabled():DisplayObjectContainer
		{
			return _disabled;
		}
		
		override public function set name(n:String):void
		{
			_name = _sb.name = n;
		}
		
		override public function get name():String
		{
			return _name;
		}
		
		public function set enabled(e:Boolean):void
		{
			_sb.enabled = _sb.mouseEnabled = e;
			
			if (!e)
				_sb.upState = _disabled;
			else
				_sb.upState = _up;		
		}
		
		public function get enabled():Boolean
		{
			return _sb.enabled;
		}
	}
}