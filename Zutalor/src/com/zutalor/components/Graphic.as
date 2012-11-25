package com.zutalor.components
{
	import com.greensock.TweenMax;
	import com.zutalor.containers.ViewObject;
	import com.zutalor.fx.Easing;
	import com.zutalor.fx.Filters;
	import com.zutalor.fx.Transition;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.GraphicItemProperties;
	import com.zutalor.properties.GraphicProperties;
	import com.zutalor.properties.GraphicStyleProperties;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.sprites.CenterSprite;
	import com.zutalor.text.Translate;
	import com.zutalor.utils.DisplayUtils;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.Resources;
	import com.zutalor.utils.ShowError;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Graphic extends Component implements IComponent
	{
		public static const LINE:String = "line";
		public static const CURVE:String = "curve";
		public static const BOX:String = "box";
		public static const ELIPSE:String = "elipse";
		public static const CIRCLE:String = "circle";
		public static const PAINT:String = "paint";
		public static const TEXT:String = "text";
		public static const GRAPHIC:String = "graphic";
		public static const EMBED:String = "embed";
		
		private var _gri:GraphicItemProperties;
		private var _grs:GraphicStyleProperties;
		private var _grm:NestedPropsManager;
		private var _canvas:CenterSprite;
		private var _canvasRect:Rectangle;
		private var _g:Graphics;

		private var _pts:Array;
		private var _data:Array;
		private var _scale9Data:Array;
		private var _grp:GraphicProperties;	
		private var _onLifeTimeComplete:Function;
		private var _onRenderComplete:Function;
		private var _frameRate:int = 60;
		private var _bmd:BitmapData;
		private var _tick:int;
		private var _tickLast:int;	
		private var _lastPos:Point;
		private var _brush:Bitmap;
		private var _brushRect:Rectangle;
		private var _lineEnd:Sprite = new Sprite();
		
		private static var _presets:PropertyManager;	
		
		public static function register(xml:XMLList):void
		{
			if (!_presets)
				_presets = new PropertyManager(GraphicStyleProperties);
			
			_presets.parseXML(xml);
		}
				
		override public function render(viewItemProperties:ViewItemProperties = null):void
		
		//id:String, delay:Number = 0, onRenderComplete:Function=null, onLifeTimeComplete:Function=null):void
		{	
			//_onLifeTimeComplete = onLifeTimeComplete;
			//_onRenderComplete = onRenderComplete;
			super.render(viewItemProperties);

			_canvas = this;
			_g = _canvas.graphics;
			_canvas.alpha = 1;
			_canvas.visible = true;
			
			if (!_grm)
				_grm = Props.graphics;
				
			if (vip.transitionDelay)
				MasterClock.callOnce(_render, vip.transitionDelay * 1000);
			else
				_render();
		}
		
		private function _render():void
		{
			var numGraphics:int;
			var scale9Rect:Rectangle;
			var bm:Bitmap;
			var txt:TextField;
			var i:int = 0;
			
			numGraphics = _grm.getNumItems(vip.graphicId);
			
			if (numGraphics == 0)
				ShowError.fail(Graphic,"Graphic Render, no items for: " + vip.presetId);
				
			renderNextItem();
			
			function renderNextItem():void
			{
				if (i == numGraphics)
				{
					if (_onRenderComplete != null)
						_onRenderComplete();
				}
				else
				{
					_gri = _grm.getItemPropsByIndex(vip.presetId, i);
					if (!_gri)
						ShowError.fail(this,"Graphic: no properties for graphic id " + vip.presetId);
					else
					{	
						if (_gri.data)
						{
							_data =  _gri.data.split(",");
							
							for (var e:int = 0; e < _data.length; e++)
								_data[e] = int(_data[e]);
						}
						if (i)
						{
							_canvas = new CenterSprite();
							_g = _canvas.graphics;
							addChild(_canvas);	
						}
							
						if (_gri.rotation)
							_canvas.rotationAroundCenter = _gri.rotation;
						
						_grs = _presets.getPropsByName(_gri.graphicStyle);
						
						if (_grs)
						{
							if (_grs.thickness)
								_g.lineStyle(_grs.thickness, _grs.lineColor, _grs.lineAlpha, false, _grs.scaleMode, _grs.caps, _grs.joints);
							
							if (_grs.fillClassName)
								_g.beginBitmapFill(Resources.createInstance(_grs.fillClassName).bitmapData, null, _grs.fillRepeat);
							else if (_grs.fillType)
							{
								var matrix:Matrix = new Matrix();
										
								matrix.createGradientBox(_data[2],_data[3], _grs.rotation * Math.PI/180);							
								_g.beginGradientFill(_grs.fillType, _grs.colorsArray, _grs.alphasArray, _grs.ratiosArray, matrix, _grs.spreadMethod);
							}
							else if (_grs.fillAlpha)
									_g.beginFill(_grs.fillColor, _grs.fillAlpha);		
						}
						else
						{
							switch (_gri.type)
							{
								case Graphic.EMBED :
								case Graphic.TEXT :
								case Graphic.GRAPHIC :
									//do nothing
									break;
								default :
									ShowError.fail(this,"Graphics, no graphic style for: ID: " + vip.presetId + " Type: " + _gri.type + "  Style: " + _gri.graphicStyle + " : " + _gri.name);
							}
						}
						switch (_gri.type)
						{
							case Graphic.LINE :
							case Graphic.CURVE :
								drawLines();
								onItemRenderComplete();
								break;
							case Graphic.BOX :
								if (_gri.scale9Data)
								{	
									_scale9Data = Vector.<int>(_gri.scale9Data.split(","));
									addPositionOffsets();
									scale9Rect = new Rectangle(_scale9Data[0], _scale9Data[1], _scale9Data[2], _scale9Data[3]); 	
								}
								else
									addPositionOffsets();
								
								if (_data.length == 4)
								{
									_data.push(0);
									_data.push(0);
								}	
								_g.drawRoundRect(_data[0], _data[1], _data[2], _data[3], _data[4], _data[5]);
								if (scale9Rect)
									this.scale9Grid = scale9Rect;
									
								onItemRenderComplete();
								break;
							case Graphic.ELIPSE :
								addPositionOffsets();
								_g.drawEllipse(_data[0], _data[1], _data[2], _data[3]);
								onItemRenderComplete();
								break;
							case Graphic.CIRCLE :
								addPositionOffsets();
								_g.drawCircle(_data[0], _data[1], _data[2]);
								onItemRenderComplete();
								break;
							case Graphic.PAINT :
								paint();
								onItemRenderComplete();
								break;
							case Graphic.EMBED :							
								bm = Resources.createInstance(_gri.className);
								bm.x = int(_gri.hPad);
								bm.y = int(_gri.vPad);
								_canvas.addChild(bm);
								onItemRenderComplete();
								break;
							case Graphic.TEXT :	
								var label:Label;
								var vip:ViewItemProperties;
								vip.text = Translate.text(_gri.tKey);
								vip.width = String(_gri.width);
								vip.height = String(_gri.height);
								vip.align = _gri.align;
								vip.hPad = _gri.hPad;
								vip.vPad = _gri.vPad;
								label = new Label();
								label.render(vip);
								label.name = name;
								_canvas.addChild(label);
								onItemRenderComplete();
								break;	
							case Graphic.GRAPHIC : // nested graphic!
								var gr:Graphic = new Graphic();
								if (!_gri.data)
									ShowError.fail(this, "Graphic: data null for " + vip.presetId);
								gr.render(vip);
								break;
						}
					}
				}
				
				function addPositionOffsets():void
				{
					_data[0] += int(_gri.hPad);
					_data[1] += int(_gri.vPad);
					
					if (_scale9Data)
					{
						_scale9Data[0] += int(_gri.hPad);
						_scale9Data[1] += int(_gri.hPad);
					}
				}
				
				function onNestedItemRenderComplete():void
				{
					gr.x = int(_gri.hPad);
					gr.y = int(_gri.vPad);
					_canvas.addChild(gr);
					onItemRenderComplete();
				}
				
				function onItemRenderComplete():void 
				{
					_grp = _grm.getPropsById(vip.presetId);
					
					if (_grp.maskGraphicId)
					{
						var mask:Graphic = new Graphic();
						vip.graphicId = _grp.maskGraphicId;
						mask.render(vip);
						_canvas.addChild(mask);
						mask.x = _grp.maskX;
						mask.y = _grp.maskY;
						_canvas.mask = mask;
					}
					
					if (_grp.lifeTime)
						MasterClock.callOnce(transitionOut, _grp.lifeTime * 1000);
					
					if (_gri.scale)
						_canvas.scaleX = _canvas.scaleY = _gri.scale;
					
					if (_grs)
					{
						if (_grs.alpha)
							_canvas.alpha = _grs.alpha;
								
						if (_grs.fillAlpha || _grs.fillLibraryName || _grs.fillType)
							_g.endFill();
					}
					if (_gri.blendMode)
						_canvas.blendMode = _gri.blendMode;
						
					if (_gri.filterPreset)
					{
						var filters:Filters = new Filters();
						filters.add(_canvas, _gri.filterPreset);		
					}					
					i++;
					renderNextItem();
				}
			}
		}
				
		private function transitionOut():void
		{
			var t:Transition = ObjectPool.getTransition();
			t.simpleRender(_canvas, _grp.transitionOut, "out", finish);
			
			function finish():void
			{
				//_canvas.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				if (_onLifeTimeComplete != null)
					_onLifeTimeComplete();
			}
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
			//_canvas.addChild(_bm);							
			setupLineData();

			if (_gri.endcap)
			{
				endcap = new Graphic();
				vip.graphicId = _gri.endcap;
				endcap.render(vip);
				_lineEnd.addChild(endcap);
				_canvas.addChild(_lineEnd);
				autoOrient = _grm.getPropsById(_gri.endcap).autoOrient;
			}
			
			if (_gri.brush)
			{
				//_brush = _bm.getBitmap(_gri.brush);
				//_brushRect = new Rectangle(0, 0, _brush.width, _brush.height);
			}
		
			//_canvas.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
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