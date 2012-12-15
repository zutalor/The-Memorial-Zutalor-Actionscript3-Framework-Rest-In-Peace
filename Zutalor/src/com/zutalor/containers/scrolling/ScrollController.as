package com.zutalor.containers.scrolling 
{
	import com.greensock.easing.Quint;
	import com.greensock.TweenMax;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.StageRef;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.system.Capabilities;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ScrollController extends EventDispatcher 
	{	
		public var ease:Function = Quint.easeOut;
		public var swipeEaseSeconds:Number = .5;
		public var OverEdgeEaseSeconds:Number = .75;
		public var movementTolerance:int = Capabilities.screenDPI / 6;
		public var velocityMultiplier:Number = 2;
	
		protected var _fullBoundsWidth:Number;
		protected var _fullBoundsHeight:Number;
		protected var _motionObject:*;
		protected var _isDown:Boolean;
		protected var _scrollRect:Rectangle;
		protected var sc:ScrollingContainer;
		
		public var spX:ScrollProperties;
		public var spY:ScrollProperties;
		
		public function ScrollController(scrollingContainer:ScrollingContainer) 
		{
			sc = scrollingContainer;
			init();
		}
		
		private function init():void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onUp, false, 0, true);
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove, false, 0, true);	
			sc.addEventListener(MouseEvent.MOUSE_DOWN, onDown, false, 0, true);

			_scrollRect = new Rectangle();
			spX = new ScrollProperties;
			spY = new ScrollProperties;
			
			spX.setPos = setScrollX;
			spX.getPos = getScrollY;
			spY.setPos = setScrollY;
			spY.getPos = getScrollY;
		}
		
		public function set scrollWidth(w:int):void
		{
			_scrollRect.width = w;
		}
		
		public function set scrollHeight(h:int):void
		{
			_scrollRect.height = h;
		}
		
		private function initializeSettings():void
		{
			var r:Rectangle;
				
			r = getFullBounds(sc);
			_fullBoundsWidth = r.width;
			_fullBoundsHeight = r.height;
			
			spX.midPos = _scrollRect.width / 2;
			spX.minPos = spX.midPos * -1;
			spX.maxPos = _fullBoundsWidth - spX.midPos;

			spY.midPos = _scrollRect.height / 2;
			spY.minPos = spY.midPos * -1;
			spY.maxPos = _fullBoundsHeight - spY.midPos;
			
			if (_fullBoundsWidth > sc.width)
				spX.scrollEnabled = true;
			else
				spX.scrollEnabled = true;
			
			if (_fullBoundsHeight > sc.height)
				spY.scrollEnabled = true;
			else
				spY.scrollEnabled = true;
				
			_scrollRect.height = sc.height;
			_scrollRect.width = sc.width;
		}
		
		public function dispose():void
		{
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			sc.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		private function onDown(me:Event):void
		{
			_isDown = true;
		    spX.downPos = sc.mouseX;
			spY.downPos = sc.mouseY;
			addEventListener(Event.ENTER_FRAME, measureVelocity, false, 0, true);
		}
		
		private function onMove(me:MouseEvent):void
		{
			if (_isDown)
			{
				spX.setPos(adjustEdge(sc.mouseX, spX)); 
				spY.setPos(adjustEdge(sc.mouseY, spY)); 
				me.updateAfterEvent();
			}
		}
		
		protected function measureVelocity(e:Event):void
		{
			spX.velocity = StageRef.stage.mouseX - spX.lastPos; 
			spY.velocity = StageRef.stage.mouseY - spY.lastPos; 
	
			spX.lastPos = StageRef.stage.mouseX;
			spY.lastPos = StageRef.stage.mouseY;
		}
				
		protected function onUp(me:Event = null):void
		{
			removeEventListener(Event.ENTER_FRAME, measureVelocity);
			_isDown = false;
			onUpForX();
			onUpForY();
			MasterClock.callOnce(conformBounds, swipeEaseSeconds * 1000);
		}
		
		private function onUpForX():void
		{	
			var destinationPos:int;
			destinationPos = spX.getPos() - spX.velocity - (25 * spX.direction);
			destinationPos += destinationPos / 50;
			destinationPos -= destinationPos % (sc.width / 8);

			if (spX.scrollEnabled && !spX.overEdge)	
				TweenMax.to(_scrollRect, swipeEaseSeconds, { x:destinationPos, onUpdate:onTween, ease:ease } );	
		}
		
		private function onUpForY():void
		{
			var destinationPos:int;
			destinationPos = spY.getPos() - spY.velocity - (25 * spY.direction);
			destinationPos += destinationPos / 50;
			destinationPos -= destinationPos % (sc.height / 8);
			if (spY.scrollEnabled && !spY.overEdge)	
				TweenMax.to(_scrollRect, swipeEaseSeconds, { y:destinationPos, onUpdate:onTween, ease:ease } );
		}
		
		protected function adjustEdge(mousePos:int, sp:ScrollProperties):int
		{
			var newPos:Number;
			
			newPos = sp.getPos() - mousePos - sp.downPos;
			
			if (newPos < sp.maxPos && newPos > sp.minPos)
				sp.overEdge = false;
			else
			{
				sp.overEdge = true;
				newPos = sp.getPos();
			}
			return newPos;
		}
		
		protected function conformBounds():void
		{
			if (spX.scrollEnabled)
			{
				if (_scrollRect.x < 0)
					TweenMax.to(_scrollRect, OverEdgeEaseSeconds, { x:0, onUpdate:onTween, ease:ease } );
				else if (_scrollRect.x + sc.width > _fullBoundsWidth)
					TweenMax.to(_scrollRect, OverEdgeEaseSeconds, { x:_fullBoundsWidth - sc.width, onUpdate:onTween, ease:ease } );
			}
			
			if (spY.scrollEnabled)
			{
				if (_scrollRect.y < 0)
					TweenMax.to(_scrollRect, OverEdgeEaseSeconds, { y:0, onUpdate:onTween, ease:ease } );
				else if (_scrollRect.y + sc.height > _fullBoundsHeight)
					TweenMax.to(_scrollRect, OverEdgeEaseSeconds, { y:_fullBoundsHeight - sc.height, onUpdate:onTween, ease:ease } );
			}	
		}
		
		protected function onTween():void
		{
			sc.scrollRect = _scrollRect;
		}
		
		public function getScrollX():Number
		{
			return _scrollRect.x;
		}
		
		public function setScrollX(n:Number):void
		{
			_scrollRect.x = n;
			sc.scrollRect = _scrollRect;
		}
		
		public function getScrollY():Number
		{
			return _scrollRect.y;
		}
		
		public function setScrollY(n:Number):void
		{
			_scrollRect.y = n;
			sc.scrollRect = _scrollRect;
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
		
		public function contentChanged():void
		{
			initializeSettings();
			if (sc.numChildren == 0)
			{
				scrollPercentX = 0;
				scrollPercentY = 0;
			}
		}
		
		protected function getFullBounds (displayObject:DisplayObject) :Rectangle
		{
			var bounds:Rectangle;
			var transform:Transform;
			var toGlobalMatrix:Matrix;
			var currentMatrix:Matrix;
		 
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