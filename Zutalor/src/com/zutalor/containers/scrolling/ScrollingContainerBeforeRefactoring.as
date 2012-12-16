package com.zutalor.containers.scrolling 
{
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	import com.greensock.TweenMax;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import flash.display.DisplayObject;
	import flash.events.Event;
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
	public class ScrollingContainerBeforeRefactoring extends ViewContainer 
	{	
		public var ease:Function = Quint.easeOut;
		public var swipeEaseSeconds:Number = .5;
		public var OverEdgeEaseSeconds:Number = .75;
		public var movementTolerance:int = Capabilities.screenDPI / 6;
		public var velocityMultiplier:Number = 2;
	
		private var _width:Number;
		private var _height:Number;
		private var _scrollRect:Rectangle;
		private var _isDown:Boolean;
		protected var _enableHScroll:Boolean;
		protected var _enableVScroll:Boolean;
		protected var _downX:int;
		protected var _downY:int;
		protected var _velX:int;
		protected var _velY:int;
		protected var _oldX:int;
		protected var _oldY:int;
		private var _xOverEdge:Boolean;
		private var _yOverEdge:Boolean;
		private var _dirY:int;
		private var _dirX:int;
		
		public function ScrollingContainer(containerName:String) 
		{
			super(containerName);
			_scrollRect = new Rectangle();
			_enableVScroll = true;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
		
		private function addedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp, false, 0, true);
			parent.addEventListener(MouseEvent.MOUSE_DOWN, onDown, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove, false, 0, true);
		}
		
		override public function dispose():void
		{
			removeEventListener(MouseEvent.MOUSE_UP, onUp);
			removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
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
		
		private function adjustXOverEdge(offset:Number):Number
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
			{
				return 0;
			}
		}
		
		private function adjustYOverEdge(offset:Number):Number
		{
			var maxY:Number;
			var minY:Number;
			var newY:Number;
			var midY:Number;
		
			midY = _scrollRect.height / 2;
			minY = midY * -1;
			maxY = _height - midY;
			newY = _scrollRect.y - offset;
			
			if (newY < maxY && newY > minY)
			{
				_yOverEdge = false;
				return newY;
			}
			else
			{
				_yOverEdge = true;
				return scrollY;
			}
		}
		
		private function onDown(me:Event):void
		{
			_isDown = true;
			_downX = mouseX;
			_downY = mouseY;
			addEventListener(Event.ENTER_FRAME, measureVelocity, false, 0, true);
		}
		
		private function onMove(me:MouseEvent):void
		{
			if (_isDown)
			{
				scrollX = adjustXOverEdge(mouseX - _downX);
				scrollY = adjustYOverEdge(mouseY - _downY);
				me.updateAfterEvent();
			}
		}
		
		private function measureVelocity(e:Event):void
		{
			_velX = StageRef.stage.mouseX - _oldX;
			_velY = StageRef.stage.mouseY - _oldY;
			_oldX = StageRef.stage.mouseX;
			_oldY = StageRef.stage.mouseY;
			
			if (_velX < 1)
				_dirX = -1;
			else if (_velX)
				_dirX = 1;
				
			if (_velY < 1)
				_dirY = -1;
			else if (_velY)
				_dirY = 1;
		}
				
		private function onUp(me:Event = null):void
		{
			var destination:int;
			
			removeEventListener(Event.ENTER_FRAME, measureVelocity);
			_isDown = false;
			destination = _scrollRect.y - _velY - (25 * _dirY);
			destination += destination / 50;
			destination -= destination % (height / 8);
			
			if (_enableVScroll && !_yOverEdge)	
			{		
				TweenMax.to(_scrollRect, swipeEaseSeconds, { y:destination, onUpdate:onTween, ease:ease, onComplete:conformBounds } );
			}
			else
				conformBounds();
		}
		
		private function conformBounds():void
		{
			if (_enableHScroll)
			{
				if (_scrollRect.x < 0)
					TweenMax.to(_scrollRect, OverEdgeEaseSeconds, { x:0, onUpdate:onTween, ease:ease } );
				else if (_scrollRect.x + width > _width)
					TweenMax.to(_scrollRect, OverEdgeEaseSeconds, { x:_width - width, onUpdate:onTween, ease:ease } );
			}
			
			if (_enableVScroll)
			{
				if (_scrollRect.y < 0)
					TweenMax.to(_scrollRect, OverEdgeEaseSeconds, { y:0, onUpdate:onTween, ease:ease } );
				else if (_scrollRect.y + height > _height)
					TweenMax.to(_scrollRect, OverEdgeEaseSeconds, { y:_height - height, onUpdate:onTween, ease:ease } );
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