package com.zutalor.containers 
{
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import com.zutalor.components.slider.Slider;
	import com.zutalor.events.ContainerEvent;
	import com.zutalor.events.UIEvent;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ScrollingContainer extends MaskedContainer 
	{		
		
		private var _autoAdjustThumbSize:Boolean;
		
		private var _scrollBarVisibleX:Boolean;
		private var _scrollBarVisibleY:Boolean;
		
		private var _vScrollBar:Slider;
		private var _hScrollBar:Slider;
		
		private var _hMinThumbWidth:int;
		private var _vMinThumbHeight:int;
		
		public function ScrollingContainer(containerName:String,
											hScrollBarSliderId:String=null, vScrollBarSliderId:String=null, autoAdjustThumbSize:Boolean = true) 
		{
			
			super(containerName);
			
			_autoAdjustThumbSize = autoAdjustThumbSize;
			
			if (vScrollBarSliderId)
			{
				
				_vScrollBar = new Slider(containerName);
				_vScrollBar.vip.presetId = vScrollBarSliderId;
				_vScrollBar.render();
				_scrollBarVisibleY = true;	
				_vMinThumbHeight = _vScrollBar.height;
				_vScrollBar.addEventListener(UIEvent.VALUE_CHANGED, vertThumbMoved, false, 0, true);
			}
			
			if (hScrollBarSliderId)
			{
				_hScrollBar = new Slider(containerName);
				_hScrollBar.vip.presetId = hScrollBarSliderId;
				_hScrollBar.render();
				
				_scrollBarVisibleX = true;
				_hMinThumbWidth = _vScrollBar.width;
				_hScrollBar.addEventListener(UIEvent.VALUE_CHANGED, horzThumbMoved, false, 0, true);
			}
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
												
		private function addedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);	
	
			checkHeight();
			checkWidth();
			
			if (_scrollBarVisibleX)
			{
				addChild(_hScrollBar);
				showUiX();
			}
			
			if (_scrollBarVisibleY)	
			{
				addChild(_vScrollBar);
				showUiY();
			}
			
			addEventListener(ContainerEvent.CONTENT_CHANGED, contentChanged, false, 0, true);
		}

		override public function get width():Number
		{
			var w:Number;
			
			if (_scrollBarVisibleY)
				w = scrollRectWidth + _vScrollBar.width;
			else
				w = scrollRectWidth * scaleX;
				
			return w * scaleX;	
		}
		
		override public function get height():Number
		{
			var h:Number
			
			if (_scrollBarVisibleX)
				h = scrollRectHeight + _hScrollBar.height * scaleY;
			else
				h = scrollRectHeight * scaleY;
			
			return h * scaleY;
		}
		
		override public function set height(n:Number):void
		{
			scrollRectHeight = n;
			checkHeight();
			
			if (_scrollBarVisibleY)
			{
				showUiY();
				
				if (_scrollBarVisibleX)
					_hScrollBar.y = scrollRectHeight;
			}
			tweenScrollPercentY(scrollPercentY);	
		}
		
		override public function set width(n:Number):void
		{
			scrollRectWidth = n;
			checkWidth();
			
			if (_scrollBarVisibleX)
			{
				showUiX();
				
				if (_scrollBarVisibleY)
					_vScrollBar.x = scrollRectWidth;
			}
			tweenScrollPercentX(scrollPercentX);
		}
		
		private function checkHeight():void
		{
			return;
			if (_scrollBarVisibleX)
			{
				if (stage)
				{
					if (scrollRectHeight * Scale.curAppScaleY >= stage.stageHeight - _hScrollBar.height)
						scrollRectHeight = (stage.stageHeight - _hScrollBar.height) * Scale.curAppScaleY;
				}
			}
			else if (stage)
				if (scrollRectHeight * Scale.curAppScaleY >= stage.stageHeight)
					scrollRectHeight = stage.stageHeight * Scale.curAppScaleY;
		}
		
		private function checkWidth():void
		{
			return;
			if (_scrollBarVisibleY) {	
				if (stage)
					if (scrollRectWidth * Scale.curAppScaleX >= stage.stageWidth - _vScrollBar.width)
						scrollRectWidth = (stage.stageWidth - _vScrollBar.width) * Scale.curAppScaleX;
			}
			else if (stage) 
				if (scrollRectWidth * Scale.curAppScaleX > stage.stageWidth)
					scrollRectWidth = stage.stageWidth * Scale.curAppScaleX;
		}
		
		override public function contentChanged(ev:ContainerEvent = null):void
		{
			if (numChildren == 0)
			{
				tweenScrollPercentX(0);
				tweenScrollPercentY(0);
			}
			if (_scrollBarVisibleX)
				showUiX();
				
			if (_scrollBarVisibleY)	
				showUiY();	
		}	
		
		private function showUiX():void
		{
			if (_scrollBarVisibleX && hScrollable)
			{
				_hScrollBar.visible = true;
				drawScrollBarX()
				drawThumbX();
			}
			else
			{
				_hScrollBar.visible = false;
			}
		}

		private function showUiY():void
		{
			if (_scrollBarVisibleY && vScrollable)
			{
				_vScrollBar.visible  = true;
				drawScrollBarY();
				drawThumbY();
			}
			else
			{
				_vScrollBar.visible  = false;
			}
		}
		
		private function drawScrollBarX():void
		{
			var adjTrackSize:int;	
			
			if (!_scrollBarVisibleY && _vScrollBar)
				adjTrackSize = _vScrollBar.width;
			else
				adjTrackSize = 0;
			
			_hScrollBar.track.width = scrollRectWidth + adjTrackSize;
				
			_hScrollBar.y = scrollRectHeight;
		}
		
		private function drawScrollBarY():void
		{
			var adjTrackSize:int;
			
			if (!_scrollBarVisibleX && _hScrollBar)
				adjTrackSize = _hScrollBar.height;
			else
				adjTrackSize = 0;

			_vScrollBar.track.height = scrollRectHeight + adjTrackSize;	
			_vScrollBar.x = scrollRectWidth;
		}
		
		private function drawThumbY():void	
		{	
			var vThumbHeight:int;
													
			if (_autoAdjustThumbSize)
			{
				vThumbHeight = scrollRectHeight / height * scrollRectHeight;							
				if (vThumbHeight < _vMinThumbHeight)
					vThumbHeight = _vMinThumbHeight;
					
				_vScrollBar.thumb.height = vThumbHeight;
			}			
		}
		
		private function drawThumbX():void	
		{	
			var hThumbWidth:int;
	
			if (_autoAdjustThumbSize)
			{
				hThumbWidth = scrollRectWidth / width * scrollRectWidth;									
				if (hThumbWidth < _hMinThumbWidth)
					hThumbWidth = _hMinThumbWidth;
					
				_hScrollBar.thumb.width = _hMinThumbWidth;
			}
		}
						
		protected function vertThumbMoved(e:UIEvent):void
		{
			tweenScrollPercentY(e.value);			
		}
		
		protected function horzThumbMoved(e:UIEvent):void
		{
			tweenScrollPercentX(e.value);
		}	
		
		override public function tweenScrollPercentY(percent:Number, tweenTime:Number = 0.5, ease:Function = null):void
		{
			var e:Function;
			if (ease == null)
				e = Quad.easeOut;
			else
				e = ease;
			
			if (percent > 1) 
				percent = 1;
			else if (percent < 0) 
				percent = 0;
				
			if (tweenTime)	
				TweenMax.to(this, tweenTime, { scrollPercentY:percent, ease:e} );
			else if (scrollPercentY != percent)
				scrollPercentY = percent;
			
			if (_scrollBarVisibleY)
				_vScrollBar.value = percent;	
		}
				
		override public function tweenScrollPercentX(percent:Number, tweenTime:Number=0.5, ease:Function=null):void
		{
			var e:Function;
			
			if (ease == null)
				e = Quad.easeOut;
			else
				e = ease;
	
			if (percent > 1) 
				percent = 1;
			else if (percent < 0) 
				percent  = 0;
			
			if (tweenTime)
				TweenMax.to(this, tweenTime, { scrollPercentX:percent, ease:e} );
			else if (scrollPercentX != percent) 
				scrollPercentX = percent;
			
			if (_scrollBarVisibleX)
				_hScrollBar.value = percent;
		}
				
		public function set autoAdjustThumbSize(val:Boolean):void
		{
			_autoAdjustThumbSize = val;
			contentChanged();
		}
	}
}