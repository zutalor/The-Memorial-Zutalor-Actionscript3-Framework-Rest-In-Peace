package com.zutalor.components
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.ViewObject;
	import com.zutalor.ui.Line;
	import com.zutalor.utils.ArrayUtils;
	import flash.display.Graphics;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Plotter extends ViewObject implements IViewObject
	{
		public var dotSize:int;		
		private var _displayData:Array;
		private var _width:Number;
		private var _height:Number;
		private var _line:Line;
		
		protected var line:Line;
				
		public function Plotter(width:Number, height:Number)
		{
			_width = width;
			_height = height;
			this.graphics.lineStyle(1, 0,1, true);
		}
				
		override public function set width(n:Number):void
		{
			_width = n;
		}
		
		override public function set height(n:Number):void
		{
			_height = n;
		}
		
		override public function get width():Number
		{
			return _width
		}
		
		override public function get height():Number
		{
			return _height
		}
		
		public function get displayData():Array
		{
			return _displayData;
		}
		
		public function cancel():void
		{
			if (_line)
				_line.cancel();
		}
		
		public function render(xA:Array, yA:Array = null, start:int = 0, end:int = int.MAX_VALUE, speed:Number=0, onComplete:Function = null):void
		{	
			_line = new Line(this);
			_displayData = [];
			if (!yA)
				_line.render(ArrayUtils.fitEvenDistribution(xA, _displayData, _width, _height, start, end), false, dotSize, speed, onComplete);
			else
				_line.render(ArrayUtils.fitUnevenDistribution(xA, yA, _displayData, start, end));
		}
				
		override public function dispose():void
		{
			_displayData = null;
			_line = null;
		}
	}
}