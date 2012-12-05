package com.zutalor.components.graphic 
{
	/**
	 * ...
	 * @author Geoff Pepos
	 */

	 // Currently a stub
	 public class Paint 
	{
		private var _frameRate:int = 60;
		private var _bmd:BitmapData;
		private var _tick:int;
		private var _tickLast:int;	
		private var _lastPos:Point;
		private var _brush:Bitmap;
		private var _brushRect:Rectangle;
		private var _lineEnd:Sprite = new Sprite();
		
		public function Paint() 
		{
			
		}
		private function paint():void
		{
			var pt:Object;
			var ease:Function;
			var autoOrient:Boolean;
			var endcap:Graphic;
			
			_lastPos = new Point();			
			//_bmd = new BitmapData(StageRef.stage.width * _Scale.curAppScaleX, StageRef.stage.height * _Scale.curAppScaleY, true, 0x000000);
			//_bm = new Bitmap(_bmd, "auto", true);
			
			//_canvasRect = new Rectangle(StageRef.stage.stageWidth * _Scale.curAppScaleX, StageRef.stage.stageHeight * _Scale.curAppScaleY);
			//addChild(_bm);							
			setupLineData();

			if (_gri.endcap)
			{
				endcap = new Graphic();
				vip.presetId = _gri.endcap;
				endcap.render(vip);
				_lineEnd.addChild(endcap);
				addChild(_lineEnd);
				autoOrient = _grm.getPropsById(_gri.endcap).autoOrient;
			}
			
			if (_gri.brush)
			{
				//_brush = _bm.getBitmap(_gri.brush);
				//_brushRect = new Rectangle(0, 0, _brush.width, _brush.height);
			}
		
			//addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			ease = Easing.getEase(_gri.easing);
			TweenMax.to(_lineEnd, _gri.paintTime, { bezierThrough:_pts, onUpdate:renderPaint, orientToBezier:autoOrient, ease:ease } );
		}
		
		private function onEnterFrame(event:Event):void 
		{ 
			_tick = int((getTimer() % 1000) / _frameRate);
			if (_tickLast != _tick)
			{ 
				_tickLast = _tick;
				_bmd.lock();
				_bmd.fillRect(_canvasRect, 0x000000);
				renderPaint();
				_bmd.unlock();
			}
		}					
			
		private function renderPaint():void
		{
			var dist:int;
			
			if (_lastPos)
			{
				if (_gri.brush) 
				{
					dist = MathG.calcDistance(_lastPos.x, _lastPos.y, _lineEnd.x, _lineEnd.y)
					for (var i:int = 0; i < dist; i++)
					{
						_bmd.copyPixels(_brush.bitmapData, _brushRect, MathG.GetPointOnLine(_lastPos.x, _lastPos.y, _lineEnd.x, _lineEnd.y, i / dist), null, null, true);
					}
				}
				else
				{
					_g.moveTo(_lastPos.x, _lastPos.y);					
					_g.lineStyle(_grs.thickness, _grs.lineColor, _grs.lineAlpha, false, _grs.scaleMode, _grs.caps, _grs.joints);
					_g.lineTo(_lineEnd.x, _lineEnd.y);
				}
			}
			_lastPos.x = _lineEnd.x;
			_lastPos.y = _lineEnd.y;				
		}		
				
		private function setupLineData():void
		{
			var c:int = 0;
							
			_pts = [];	
			
			for (var i:int = 0; i < _data.length; i++)
			{
				if (i % 2)
				{
					_pts[c].y = int(_data[i]) + _gri.vPad;
					c++;
				}				
				else
				{
					_pts[c] = new Object();
					_pts[c].x = int(_data[i]) + _gri.hPad;
				}
			}			
		}		
		
		private function drawLines():void
		{
			var i:int;
			var l:int;
			var midpt:Point = new Point();
			var pt1:Point = new Point();
			var pt2:Point = new Point();			
			var prevMidPoint:Point = new Point;

			setupLineData();
			
			l = _pts.length;
			
			if (_gri.type == Graphic.CURVE)
				curves();
			else
				lines();
					
			function lines():void
			{
				_g.moveTo(_pts[0].x, _pts[0].y);
				_g.lineTo(_pts[1].x, _pts[1].y);
				for (i = 2; i < l; i++)
				{
					_g.lineTo(_pts[i-1].x, _pts[i-1].y);
				}
				_g.lineTo(_pts[i-1].x, _pts[i-1].y);
			}
			
			function curves():void
			{
				
				for (i = 1; i < l; i++)
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
		}		
		
	}

}