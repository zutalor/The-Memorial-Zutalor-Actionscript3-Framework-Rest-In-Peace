package com.zutalor.containers 
{
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import com.zutalor.components.slider.Slider;
	import com.zutalor.events.ContainerEvent;
	import com.zutalor.events.UIEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ScrollingContainer extends ViewContainer 
	{		
		private var _scrollRect:Rectangle;
		
		public function ScrollingContainer(containerName:String = null) 
		{
			
			super(containerName);
			_scrollRect = new Rectangle();
			this.scrollRect = _scrollRect;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
												
		private function addedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);	
			addEventListener(ContainerEvent.CONTENT_CHANGED, contentChanged, false, 0, true);
		}
		
		public function get scrollX():Number
		{
			return _scrollRect.x;
			
		}
		
		public function set scrollX(n:Number):void
		{
			_scrollRect.x = n;
			scrollRect = _scrollRect;
		}
		
		public function get scrollY():Number
		{
			return _scrollRect.y;
		}
		
		public function set scrollY(n:Number):void
		{
			_scrollRect.y = n;
			scrollRect = _scrollRect;
		}
		
		public function get scrollWidth():Number
		{
			return _scrollRect.width;
		}
		
		public function get scrollHeight():Number
		{
			return _scrollRect.height;
		}
		
		public function set scrollHeight(n:Number):void
		{
			_scrollRect.height = n;
			scrollRect = _scrollRect;
			tweenScrollPercentY(scrollPercentY);	
		}
		
		public function set scrollWidth(n:Number):void
		{
			_scrollRect.width = n;
			scrollRect = _scrollRect;
			tweenScrollPercentX(scrollPercentX);
		}
		
		override public function contentChanged(ev:ContainerEvent = null):void
		{
			if (numChildren == 0)
			{
				tweenScrollPercentX(0);
				tweenScrollPercentY(0);
			}
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
		}
	}
}