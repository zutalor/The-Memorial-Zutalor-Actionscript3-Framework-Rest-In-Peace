package com.zutalor.widgets
{
	import com.zutalor.interfaces.IContainerObject;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.utils.ArrayUtils;
	import com.zutalor.widgets.Line;
	/**
	 * 
	 * @author Geoff Pepos
	 */
	public class Plotter extends ContainerObject implements IContainerObject
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
		
		public function draw(xA:Array, yA:Array = null, start:int = 0, end:int = int.MAX_VALUE, speed:Number=1, onComplete:Function = null):void
		{	
			_line = new Line(this);
			_displayData = [];
			if (!yA)
				_line.render(ArrayUtils.fitEvenDistribution(xA, _displayData, _width, _height, start, end), false, dotSize, speed, onComplete);
			else
				_line.render(ArrayUtils.fitUnevenDistribution(xA, yA, _displayData, start, end), false, dotSize, speed, onComplete);
		}
				
		override public function dispose():void
		{
			_displayData = null;
			_line = null;
		}
	}
}