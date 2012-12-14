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
	import flash.system.Capabilities;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ScrollingContainer extends ViewContainer 
	{	
		public var ease:Function = Quint.easeOut;
		public var swipeEaseSeconds:Number = .5;
		public var overShootEaseSeconds:Number = .75;
		public var swipeOffsetMultiplier:Number = 25;
	
		private var _width:Number;
		private var _height:Number;
		private var _scrollRect:Rectangle;
		private var _mouseIsDown:Boolean;
		protected var _enableHScroll:Boolean;
		protected var _enableVScroll:Boolean;
		protected var _oldMouseX:Number;
		protected var _oldMouseY:Number;
		protected var _velocityX:Number;
		protected var _velocityY:Number;
		
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
			//addGestureListener("panGesture", onPanGesture);
			//addGestureListener("swipeGesture", onSwipeGesture);
			//addGestureListener("flickGesture", onSwipeGesture);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			addEventListener(MouseEvent.ROLL_OVER, onMouseMove, false, 0, true);
			
		}
		
		override public function dispose():void
		{
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
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
			scrollRect = _scrollRect;
			//tweenScrollPercentY(scrollPercentY);	
		}
		
		public function set scrollWidth(n:Number):void
		{
			_scrollRect.width = n;
			scrollRect= _scrollRect;
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
			var offsetX:Number = age.gesture.offsetX * swipeOffsetMultiplier;
			var offsetY:Number = age.gesture.offsetY * swipeOffsetMultiplier;

			TweenMax.to(_scrollRect, swipeEaseSeconds, { x:getX(offsetX), onUpdate:onTween, onComplete:onSwipeComplete } );
			TweenMax.to(_scrollRect, swipeEaseSeconds, { y:getY(offsetY), onUpdate:onTween, onComplete:onSwipeComplete } );
																		
			function onSwipeComplete():void
			{
				if (!_mouseIsDown)
					onMouseUp();
			}
		}

		private function onPanGesture(age:*):void
		{
			scrollX = getX(age.gesture.offsetX);
			scrollY = getY(age.gesture.offsetY);
		}
		
		private function getX(offset:Number):Number
		{
			var maxX:Number;
			var newX:Number;
			
			if (!_enableHScroll)
				return 0;
			
			maxX = _scrollRect.width / 2 * -1;
			newX = scrollX - offset;
			
			if (newX > maxX)
				return maxX;
			else if (newX < width)
				return newX;
			else
				return 0;
		}
		
		private function getY(offset:Number):Number
		{
			var maxY:Number;
			var minY:Number;
			var newY:Number;
			var midY:Number;
			
			if (!_enableVScroll)
				scrollY;
			
			midY = _scrollRect.height / 2;
			minY = midY * -1;
			maxY = _height - midY;
			newY = scrollY - offset;
			
			if (newY < maxY && newY > minY)
				return newY;
			else	
				return scrollY;
		}
		
		private function onMouseDown(me:MouseEvent):void
		{
			_mouseIsDown = true;
			_oldMouseX = mouseX;
			_oldMouseY = mouseY;
		}
		
		private function onMouseMove(me:MouseEvent):void
		{
			if (_mouseIsDown)
			{
				me.updateAfterEvent();
				scrollX = getX(mouseX - _oldMouseX);
				scrollY = getY(mouseY - _oldMouseY);
			}
		}
		
		private function onRollOut(me:MouseEvent):void
		{
			if (stage.mouseX >= x || stage.mouseX >= y + width)
			{
				trace("on roll out", me.target);
				onMouseUp(me);
			}
		}
		
		private function onMouseUp(me:MouseEvent = null):void
		{
			_mouseIsDown = false;
			if (_enableHScroll)
			{
				if (_scrollRect.x < 0)
					TweenMax.to(_scrollRect, overShootEaseSeconds, { x:0, onUpdate:onTween, ease:ease } );
				else if (_scrollRect.x + width > _width)
					TweenMax.to(_scrollRect, overShootEaseSeconds, { x:_width - width, onUpdate:onTween, ease:ease } );;
			}
			
			if (_enableVScroll)
			{
				if (_scrollRect.y < 0)
					TweenMax.to(_scrollRect, overShootEaseSeconds, { y:0, onUpdate:onTween, ease:ease } );
				else if (_scrollRect.y + height > _height)
					TweenMax.to(_scrollRect, overShootEaseSeconds, { y:_height - height, onUpdate:onTween, ease:ease } );;
			}	
		}
		
		private function onTween():void
		{
			scrollRect = _scrollRect;
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