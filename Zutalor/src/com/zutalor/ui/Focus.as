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
	public class Focus extends Sprite
	{
		private static var _container:DisplayObjectContainer;
		private static var _s:Sprite = new Sprite();
		public static var enabled:Boolean;
		
		public static function show(obj:*, container:DisplayObjectContainer, color:uint = 0x0067CE, padding:int = 1):void
		{
			if (enabled && obj)
			{
				_s.graphics.clear();
				_s.graphics.lineStyle(2, color);
				_s.graphics.drawRoundRect(0 - padding, 0 - padding, obj.width + padding * 2, obj.height + padding * 2, 5, 5);
				_s.x = obj.x;
				_s.y = obj.y;
				_container = container;
				_container.addChild(_s);
			}
		}
		
		public static function hide():void
		{
			if (_container)
			{
				_container.removeChild(_s);
				_container = null;
			}
		}
	}
}