package com.zutalor.ui
{
	import com.zutalor.utils.Scale;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Line  
	{
		private var _pts:Array;
		private var _data:Array;
		private var _g:Graphics;
		private var _dotSize:int;
		private var _duration:uint;
		private var _i:uint;
		private var _draw:Function;
		private var _onCompete:Function;
		private var _interval:uint;
		private var _drawing:Boolean;
		private var _view:Sprite;
		private var _rendering:Boolean;
		
		public function Line(view:Sprite)
		{
			_view = view;
			_g = view.graphics;
		}
			
		public function render(data:Array, curves:Boolean=false, dotSize:Number = 0, speed:Number = 1, onComplete:Function = null):void
		{
			_data = data;
			_dotSize = dotSize;
			
			if (_rendering)
			{
				cancel();
			}
			
			if (!speed)
				_duration = 1;
			else
				_duration = speed * 1000;
			
			_onCompete = onComplete;
			
			if (curves)
				renderCurves();
			else
				if (!dotSize)
					_render(renderLineSegment);			
				else
					_render(renderDots);
		}
		
		public function cancel():void
		{
			_view.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_rendering = false;
			_g.clear();
		}
		
		private function _render(draw:Function):void
		{
			var l:uint;
			
			_draw = draw;
			
			l = _data.length - 1;
			_g.moveTo(_data[0], _data[1]);
			draw(i);
			
			if (!_duration)
			{
				for (var i:int = 2; i < l; i += 2)
					draw(i);
				
				if (_onCompete != null)
						_onCompete();
			}
			else
			{
				_i = 2;
				_interval =  10 / _duration * 1000 * (1 / _view.stage.frameRate / 30 * 1000);
				if (!_interval)
					_interval = 1;
					
				_view.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				_rendering = true;
			}
		}
		
		private function renderLineSegment(i:uint):void
		{
			_g.lineTo(_data[i], _data[i + 1]);
		}
		
		private function renderDots(i:uint):void
		{	
			_g.drawCircle(_data[i], _data[i + 1], _dotSize);
		}
		
		private function onEnterFrame(e:Event):void
		{	
			if (!_drawing)
			{
				_drawing = true;
				if (_i < _data.length)
				{
					for (var i:int = 0; i < _interval && _i < _data.length; i++)
					{
						_draw(_i);
						_i += 2;
					}
				}
				else
				{
					_view.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					if (_onCompete != null)
						_onCompete();
				}
				_drawing = false;
			}
		}
					
		private function renderCurves():void // no duration for this
		{	
			var midpt:Point = new Point();
			var pt1:Point = new Point();
			var pt2:Point = new Point();			
			var prevMidPoint:Point = new Point;
			
			setupPoints();
			
			for (var i:int = 1; i < _pts.length; i++)
			{
				pt1.x = _pts[i - 1].x;
				pt1.y = _pts[i - 1].y;
				pt2.x = _pts[i].x;
				pt2.y = _pts[i].y;
				
				midpt.x = (pt1.x + (pt2.x - pt1.x)) >> 1;
				midpt.y = (pt1.y + (pt2.y - pt1.y)) >> 1;
			
				if (prevMidPoint) 
				{
					_g.moveTo(prevMidPoint.x, prevMidPoint.y);
					_g.curveTo(pt1.x,pt1.y, midpt.x, midpt.y);
				} else {
					// draw start segment:
					_g.moveTo(pt1.x,pt1.y);
					_g.lineTo(midpt.x,midpt.y);
				}
				prevMidPoint.x = midpt.x;
				prevMidPoint.y = midpt.y;
			}
			_g.lineTo(_pts[i - 1].x, _pts[i - 1].y);
		}
		
		private function setupPoints():void
		{
			var c:int = 0;
							
			_pts = [];	
			
			for (var i:int = 0; i < _data.length; i++)
			{
				if (i % 2)
				{
					_pts[c].y = Math.round(_data[i]);
					c++;
				}				
				else
				{
					_pts[c] = new Object();
					_pts[c].x = Math.round(_data[i]);
				}
			}
		}
	}
}