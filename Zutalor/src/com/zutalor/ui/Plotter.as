package com.zutalor.ui
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.components.interfaces.IViewObject;
	import com.zutalor.containers.ViewObject;
	import com.zutalor.interfaces.IMediaPlayer;
	import com.zutalor.ui.Line;
	import com.zutalor.utils.ArrayUtils;
	import flash.display.Graphics;
	import flash.display.Sprite;
	/**
	 * 
	 * @author Geoff Pepos
	 */
	public class Plotter extends ViewObject implements IDisposable
	{
		public var dotSize:int;		
		private var _displayData:Array;
		private var _line:Line;
		private var _width:int;
		private var _height:int;
		
		protected var line:Line;
				
		public function Plotter(width:int, height:int)
		{
			_width = width;
			_height = height;
			this.graphics.lineStyle(1, 0,1, true);
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
		
		public function draw(xA:Array, yA:Array = null, start:int = 0, end:int = int.MAX_VALUE, speed:Number=0, onComplete:Function = null):void
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