package com.zutalor.scroll
{
	import com.greensock.easing.Quint;
	import com.greensock.TweenMax;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.utils.StageRef;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ScrollController extends EventDispatcher
	{
		public var ease:Function = Quint.easeOut;
		public var positionEaseSeconds:Number = .5;
		public var resetEaseSeconds:Number = .75;
		public var slipFactor:Number = 0;
		public var edgeElastisityH:Number = .5;
		public var edgeElastisityV:Number = 0.5;
		public var quantizeHPosition:Boolean;
		public var quantizeVPosition:Boolean;
		public var onPositionUpdate:Function;
		
		private var co:ContainerObject;
		private var spX:ScrollProperties;
		private var spY:ScrollProperties;
		private var tweenObject:Object;
		private var _width:Number;
		private var _height:Number;
		private var scrollPoint:Point;
		private var objectScrolling:*;
		
		public static const FORWARD:int = 1;
		
		public function ScrollController(containerObject:ContainerObject)
		{
			co = containerObject;
			init();
		}
		
		public function initialize(fullBoundsWidth:int, fullBoundsHeight:int, scrollAreaWidth:int, scrollAreaHeight:int, itemWidth:int, itemHeight:int):void
		{
			setScrollProperties(spX, fullBoundsWidth, scrollAreaWidth, itemWidth, quantizeHPosition, edgeElastisityH);
			setScrollProperties(spY, fullBoundsHeight, scrollAreaHeight, itemHeight, quantizeVPosition, edgeElastisityV);
			addListeners();
		}
		
		public function get scrollX():Number
		{
			return scrollPoint.x;
		}
		
		public function set scrollX(n:Number):void
		{
			scrollPoint.x = n;
			onPositionUpdate(scrollPoint, objectScrolling);
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
			return scrollPoint.y;
		}
		
		public function set scrollY(n:Number):void
		{
			scrollPoint.y = n;
			onPositionUpdate(scrollPoint, objectScrolling);
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
		
		protected function init():void
		{
			scrollPoint = new Point();
			tweenObject = new Object();
			spX = new ScrollProperties;
			spY = new ScrollProperties;
			spX.setCurPos = function(n:Number):void
			{
				scrollX = n;
			}
			spX.getCurPos = function():Number
			{
				return scrollX;
			}
			spY.setCurPos = function(n:Number):void
			{
				scrollY = n;
			}
			spY.getCurPos = function():Number
			{
				return scrollY;
			}
			addListeners();
		}
		
		protected function setScrollProperties(sp:ScrollProperties, fullBoundsSize:int, scrollSize:int, 
									itemSize:int, quantizePosition:Boolean, edgeElastisity:Number):void
		{
			if (fullBoundsSize > scrollSize)
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
			StageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			co.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		protected function removeListeners():void
		{
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			co.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		protected function onDown(me:Event):void
		{
			TweenMax.killTweensOf(scrollPoint);
			spX.downPos = co.mouseX;
			spY.downPos = co.mouseY;
			objectScrolling = me.target;
			co.addEventListener(Event.ENTER_FRAME, measureVelocity);
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		}
		
		protected function onMove(me:MouseEvent):void
		{
			if (spX.scrollingEnabled)
				spX.setCurPos(scroll(co.mouseX, spX));
			
			if (spY.scrollingEnabled)
				spY.setCurPos(scroll(co.mouseY, spY));
			
			me.updateAfterEvent();
		}
		
		protected function scroll(mousePos:Number, sp:ScrollProperties):int
		{
			var scrollToPos:Number;
			var offset:Number;
			
			offset = mousePos - sp.downPos;
			
			scrollToPos = sp.getCurPos() - offset;
			
			if (scrollToPos + sp.overScrollLimit > sp.elasticMaxPos)
			{
				scrollToPos = sp.elasticMaxPos;
				sp.atScrollLimit = true;
			}
			else if (scrollToPos + sp.overScrollLimit < sp.elasticMinPos)
			{
				scrollToPos = sp.elasticMinPos;
				sp.atScrollLimit = true;
			}
			else
			{
				sp.atScrollLimit = false;
				scrollToPos += calcSlip(sp, scrollToPos);
			}
			return scrollToPos;
		}
		
		protected function calcSlip(sp:ScrollProperties, scrollToPos:Number):Number
		{
			var overScrollLimit:int;
			
			if (scrollToPos < 0)
				sp.overScrollLimit = Math.abs(scrollToPos);
			
			else if (scrollToPos + sp.scrollSize > sp.fullBoundsSize)
			{
				sp.overScrollLimit = sp.fullBoundsSize - sp.scrollSize - scrollToPos;
			}
			overScrollLimit += sp.overScrollLimit * slipFactor;
			sp.overScrollLimit = overScrollLimit;
			return overScrollLimit;
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
			co.removeEventListener(Event.ENTER_FRAME, measureVelocity);
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			spX.overScrollLimit = spY.overScrollLimit = 0;
			moveToPosition();
		}
		
		protected function doTween(seconds:Number):void
		{
			TweenMax.to(scrollPoint, seconds, tweenObject);
		}
		
		protected function onTweenUpdate():void
		{
			onPositionUpdate(scrollPoint,  objectScrolling);
		}
		
		protected function moveToPosition():void
		{
			if (!spX.atScrollLimit || !spY.atScrollLimit)
			{
				tweenObject.x = getUpdatedPosition(spX);
				tweenObject.y = getUpdatedPosition(spY);
				tweenObject.ease = ease;
				tweenObject.onUpdate = onTweenUpdate;
				tweenObject.onComplete = resetPositionIfStretchingEdge;
				doTween(positionEaseSeconds);
			}
			else
				resetPositionIfStretchingEdge();
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
				updatedPos = sp.getCurPos() - sp.velocity - (sp.itemSize * 0.5 * sp.direction * dir);
				updatedPos += updatedPos / sp.itemSize;
				updatedPos -= updatedPos % (sp.scrollSize / sp.itemsPerPage);
			}
			return updatedPos;
		}
		
		protected function resetPositionIfStretchingEdge():void
		{
			var oldX:int;
			var oldY:int;
			
			oldX = spX.getCurPos();
			oldY = spY.getCurPos();
			
			tweenObject.x = getResetPositionIfStretchingEdge(spX);
			tweenObject.y = getResetPositionIfStretchingEdge(spY);
			
			if (tweenObject.x != oldX || tweenObject.y != oldY)
			{
				TweenMax.killTweensOf(scrollPoint);
				tweenObject.onUpdate = onTweenUpdate;
				tweenObject.ease = ease;
				tweenObject.onComplete = null;
				doTween(resetEaseSeconds);
			}
		}
		
		protected function getResetPositionIfStretchingEdge(sp:ScrollProperties):Number
		{
			var resetPos:Number;
			var curPos:Number;
			
			curPos = resetPos = sp.getCurPos();
			if (sp.scrollingEnabled && curPos)
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