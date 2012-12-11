package com.zutalor.containers 
{
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ScrollingContainer extends ViewContainer 
	{	
		public var ease:Function = Quint.easeOut;
		public var easeSeconds:Number = .75;
		private var _width:Number;
		private var _height:Number;
		private var _scrollRect:Rectangle;
		protected var _enableHScroll:Boolean;
		protected var _enableVScroll:Boolean;
		
		
		public function ScrollingContainer(containerName:String, enableHScroll:Boolean, enableVScroll:Boolean) 
		{
			super(containerName);
			_scrollRect = new Rectangle();
			_enableHScroll =  enableHScroll;
			_enableVScroll = enableVScroll;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
	
		private function addedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			addGestureListener("panGesture", onPanGesture);
			addGestureListener("swipeGesture", onSwipeGesture);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}
		
		override public function dispose():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeGestureListener("panGesture");
			removeGestureListener("swipeGesture");
			super.dispose();
		}
		
		public function get scrollX():Number
		{
			return _scrollRect.x;
		}
		
		public function set scrollX(n:Number):void
		{
			_scrollRect.x = n;
			scrollRect= _scrollRect;
		}
		
		public function get scrollY():Number
		{
			return _scrollRect.y;
		}
		
		public function set scrollY(n:Number):void
		{
			_scrollRect.y = n;
			scrollRect= _scrollRect;
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
			//scrollRect = _scrollRect;
			//tweenScrollPercentY(scrollPercentY);	
		}
		
		public function set scrollWidth(n:Number):void
		{
			_scrollRect.width = n;
			//scrollRect= _scrollRect;
			//tweenScrollPercentX(scrollPercentX);
		}
		
		public function set scrollPercentX(percent:Number):void
		{
		}
		
		public function get scrollPercentX():Number
		{
			return 1;
		}
		
		public function set scrollPercentY(percent:Number):void
		{
		}
		
		public function get scrollPercentY():Number
		{
			return 1;
		}
		
		override public function contentChanged():void
		{
			var r:Rectangle;
				
			r = getFullBounds(this);
			_width = r.width;
			_height = r.height;
			if (numChildren == 0)
			{
				tweenScrollPercentX(0);
				tweenScrollPercentY(0);
			}
		}
		
		public function tweenScrollPercentY(percent:Number, tweenTime:Number = 0.5):void
		{			
			if (percent > 1) 
				percent = 1;
			else if (percent < 0) 
				percent = 0;
				
			if (tweenTime)	
				TweenMax.to(this, tweenTime, { scrollPercentY:percent, ease:ease} );
			else if (scrollPercentY != percent)
				scrollPercentY = percent;
		}
				
		public function tweenScrollPercentX(percent:Number, tweenTime:Number=0.5):void
		{
			if (percent > 1) 
				percent = 1;
			else if (percent < 0) 
				percent  = 0;
			
			if (tweenTime)
				TweenMax.to(this, tweenTime, { scrollPercentX:percent, ease:ease} );
			else if (scrollPercentX != percent) 
				scrollPercentX = percent;
		}
		
		private function onSwipeGesture(age:*):void
		{
			if (_enableHScroll)
				TweenMax.to(_scrollRect, easeSeconds, { x:_scrollRect.x - (age.gesture.offsetX * 20), onUpdate:onTween, 
																		onComplete:onSwipeComplete } );
			
			if (_enableVScroll)
				TweenMax.to(_scrollRect, easeSeconds, { y:_scrollRect.y - (age.gesture.offsetY * 20), onUpdate:onTween,
																		onComplete:onSwipeComplete } );
																		
			function onSwipeComplete():void
			{
				onMouseUp();
			}
		}

		private function onPanGesture(age:*):void
		{
			TweenMax.killTweensOf(_scrollRect);
			if (_enableHScroll && scrollX - age.gesture.offsetX > _scrollRect.width / 2 * -1
								&& scrollX - age.gesture.offsetX < width)
				scrollX -= age.gesture.offsetX;
			
			if (_enableVScroll && scrollY - age.gesture.offsetY > _scrollRect.height / 2 * -1
													&& scrollY - age.gesture.offsetY < height)
					scrollY -= age.gesture.offsetY;
		}
		
		private function onMouseUp(me:MouseEvent = null):void
		{			
			if (_enableHScroll)
			{
				if (_scrollRect.x < 0)
					TweenMax.to(_scrollRect, easeSeconds, { x:0, onUpdate:onTween, ease:ease } );
				else if (_scrollRect.x + width > _width)
					TweenMax.to(_scrollRect, easeSeconds, { x:_width - width, onUpdate:onTween, ease:Quart.easeInOut } );;
			}
			
			if (_enableVScroll)
			{
				if (_scrollRect.y < 0)
					TweenMax.to(_scrollRect, easeSeconds, { y:0, onUpdate:onTween, ease:ease } );
				else if (_scrollRect.y + height > _height)
					TweenMax.to(_scrollRect, easeSeconds, { y:_height - height, onUpdate:onTween, ease:ease } );;
			}	
		}
		
		private function onTween():void
		{
			//scrollRect = _scrollRect;
		}
		
		private function getFullBounds ( displayObject:DisplayObject ) :Rectangle
		{
			var bounds:Rectangle, transform:Transform,
								toGlobalMatrix:Matrix, currentMatrix:Matrix;
		 
			transform = displayObject.transform;
			currentMatrix = transform.matrix;
			toGlobalMatrix = transform.concatenatedMatrix;
			toGlobalMatrix.invert();
			transform.matrix = toGlobalMatrix;
		 
			bounds = transform.pixelBounds.clone();
		 
			transform.matrix = currentMatrix;
		 
			return bounds;
		}
	}
}