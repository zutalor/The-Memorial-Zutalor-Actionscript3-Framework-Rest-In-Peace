package com.zutalor.containers.scrolling 
{
	import com.greensock.easing.Quint;
	import com.greensock.TweenMax;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.utils.FullBounds;
	import com.zutalor.utils.StageRef;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ScrollController extends EventDispatcher implements IDisposable
	{	
		public var ease:Function = Quint.easeOut;
		public var positionEaseSeconds:Number = .5;
		public var resetEaseSeconds:Number = .75;
		public var slipFactor:Number = .3;
		public var edgeElastisityH:Number = .8;
		public var edgeElastisityV:Number = 0.5;
		public var quantizeHPosition:Boolean;
		public var quantizeVPosition:Boolean;
		
		private var scrollRect:Rectangle;
		private var sc:ScrollingContainer;
		private var spX:ScrollProperties;
		private var spY:ScrollProperties;
		private var tweenObject:Object;
		
		public static const FORWARD:int = 1;
		
		public function ScrollController(scrollingContainer:ScrollingContainer) 
		{
			sc = scrollingContainer;
			sc.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		public function set width(n:Number):void
		{
			scrollRect.width = n;
			sc.scrollRect = scrollRect;
			trace(scrollRect.width);
		}
		
		public function set height(n:Number):void
		{
			scrollRect.height = n;
			sc.scrollRect = scrollRect;
		}
		
		public function contentChanged():void
		{
			var r:Rectangle;
			var listItem:ContainerObject;
						
			r = FullBounds.get(sc);
			listItem = sc.getChildAt(0) as ContainerObject;
			setScrollProperties(spX, r.width, scrollRect.width, listItem.width, quantizeHPosition, edgeElastisityH);
			setScrollProperties(spY, r.height, scrollRect.height, listItem.height, quantizeVPosition, edgeElastisityV);	
		}
	
		public function get scrollX():Number
		{
			return scrollRect.x;
		}
		
		public function set scrollX(n:Number):void
		{
			scrollRect.x = n;
			sc.scrollRect = scrollRect;
		}
		
		public function set scrollXPercent(n:Number):void
		{
			if (n < 0 || n > 1)
				return;
			else
				scrollX = spX.scrollSize * n;
		}
		
		public function get scrollY():Number
		{
			return scrollRect.y;
		}
		
		public function set scrollY(n:Number):void
		{
			scrollRect.y = n;
			sc.scrollRect = scrollRect;			
		}
		
		public function set scrollYPercent(n:Number):void
		{
			if (n < 0 || n > 1)
				return;
			else
				scrollY = n * spY.scrollSize;
		}
		
		public function dispose():void
		{
			removeListeners();
		}
		
		// PROTECTED METHODS
		
		protected function init(e:Event):void
		{
			scrollRect = new Rectangle();
			tweenObject = new Object();
			spX = new ScrollProperties;
			spY = new ScrollProperties;
			spX.setCurPos = function(n:Number):void { scrollX = n; } 
			spX.getCurPos = function():Number { return scrollX; }
			spY.setCurPos = function(n:Number):void { scrollY = n; } 
			spY.getCurPos = function():Number { return scrollY; }
			addListeners();
		}
		
		protected function setScrollProperties(sp:ScrollProperties, 
							fullBoundsSize:int, scrollSize:int, itemSize:int, quantizePosition:Boolean, edgeElastisity:Number):void
		{
			if (fullBoundsSize >= scrollSize)
			{
				sp.scrollingEnabled = true;
				sp.elasticMinPos = scrollSize * edgeElastisity * -1;
				sp.elasticMaxPos = fullBoundsSize - (scrollSize * (1 - edgeElastisity));
				sp.fullBoundsSize = fullBoundsSize;
				sp.scrollSize = scrollSize;
				sp.itemSize = itemSize;
				sp.itemsPerPage = scrollSize / sp.itemSize;
				if (sp.itemSize <= sp.scrollSize)
					sp.quantizePosition = quantizePosition;
			}
			else
			{
				sp.atScrollLimit = true;
				sp.scrollingEnabled = false;
			}
		}
		
		protected function addListeners():void
		{
			sc.removeEventListener(Event.ADDED_TO_STAGE, init);
			sc.stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			sc.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		protected function removeListeners():void
		{
			sc.stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			sc.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			sc.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		protected function onDown(me:Event):void
		{
			TweenMax.killTweensOf(scrollRect);
			spX.downPos = sc.mouseX;
			spY.downPos = sc.mouseY;
			sc.addEventListener(Event.ENTER_FRAME, measureVelocity);
			sc.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);	
		}
		
		protected function onMove(me:MouseEvent):void
		{
			if (spX.scrollingEnabled)
				spX.setCurPos(scroll(sc.mouseX, spX)); 
			
			if (spY.scrollingEnabled)	
				spY.setCurPos(scroll(sc.mouseY, spY)); 
			
			me.updateAfterEvent();
		}
		
		protected function scroll(mousePos:Number, sp:ScrollProperties):int
		{
			var scrollToPos:Number;
			var offset:Number;
			
			offset = mousePos - sp.downPos;
			scrollToPos = sp.getCurPos() - offset;
			
			if (scrollToPos - sp.overScroll < sp.elasticMaxPos && scrollToPos + sp.overScroll > sp.elasticMinPos)
			{	
				sp.atScrollLimit = false;
				scrollToPos += calcSlip(sp, scrollToPos);
			}
			else
			{
				sp.atScrollLimit = true;
				scrollToPos = sp.getCurPos();
			}
			return scrollToPos;
		}
		
		protected function calcSlip(sp:ScrollProperties, scrollToPos:Number):Number
		{
			var overScroll:int;

			if (scrollToPos < 0)
				sp.overScroll = Math.abs(scrollToPos);

			else if (scrollToPos + sp.scrollSize > sp.fullBoundsSize)
			{
				sp.overScroll = sp.fullBoundsSize - sp.scrollSize - scrollToPos;
			}
			overScroll += sp.overScroll * slipFactor;
			sp.overScroll = overScroll;
			return overScroll;
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
			sc.removeEventListener(Event.ENTER_FRAME, measureVelocity);
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			spX.overScroll = spY.overScroll = 0;
			adjustPosition();
		}
		
		protected function doTween(seconds:Number):void
		{
			TweenMax.to(scrollRect, seconds, tweenObject);	
		}
		
		protected function onTween():void
		{
			sc.scrollRect = scrollRect;
		}
		
		protected function adjustPosition():void
		{
			if (!spX.atScrollLimit || !spY.atScrollLimit)
			{
				tweenObject.x = getUpdatedPosition(spX);
				tweenObject.y = getUpdatedPosition(spY);
				tweenObject.ease = ease;
				tweenObject.onUpdate = onTween;
				tweenObject.onComplete = resetPositionIfOverScrollBounds;
				doTween(positionEaseSeconds);
			}
			else
				resetPositionIfOverScrollBounds();
		}
		
		protected function getUpdatedPosition(sp:ScrollProperties):int
		{
			var updatedPos:Number;
			var dir:Number;
			
			if (sp.atScrollLimit)
				updatedPos = sp.getCurPos();
			else if (!sp.quantizePosition)
				updatedPos = sp.getCurPos() - sp.velocity;
			else	
			{
				dir = sp.direction * -1;
				updatedPos = sp.getCurPos() - sp.velocity - (sp.itemSize * 0.5  * sp.direction * dir);
				updatedPos += updatedPos / sp.itemSize;
				updatedPos -= updatedPos % (sp.scrollSize / sp.itemsPerPage);
			}
			return updatedPos;
		}
		
		protected function resetPositionIfOverScrollBounds():void
		{
			var oldX:int;
			var oldY:int;

			oldX = spX.getCurPos();
			oldY = spY.getCurPos();
			
			tweenObject.x = getResetPosition(spX);
			tweenObject.y = getResetPosition(spY);
			
			if (tweenObject.x != oldX || tweenObject.y != oldY)
			{		
				TweenMax.killTweensOf(scrollRect);
				tweenObject.onUpdate = onTween;
				tweenObject.ease = ease;
				tweenObject.onComplete = null;
				doTween(resetEaseSeconds);
			}
		}			
		
		protected function getResetPosition(sp:ScrollProperties):Number
		{
			var resetPos:Number;
			var curPos:Number;
		
			curPos = resetPos = sp.getCurPos();
			if (sp.scrollingEnabled  && curPos)
			{
				if (curPos < 0)
					resetPos = 0;
				else if (curPos + sp.scrollSize > sp.fullBoundsSize)
					resetPos = sp.fullBoundsSize - sp.scrollSize;
			}
			return resetPos;
		}
	}
}