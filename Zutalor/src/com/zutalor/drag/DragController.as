package com.zutalor.drag 
{
	import com.greensock.easing.Quint;
	import com.greensock.TweenMax;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.utils.StageRef;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class DragController extends EventDispatcher implements IDisposable
	{	
		public var ease:Function = Quint.easeOut;
		public var positionEaseSeconds:Number = .5;
		public var resetEaseSeconds:Number = .75;
		public var slipFactor:Number = .3;
		public var edgeElastisityH:Number = .5;
		public var edgeElastisityV:Number = 0.5;
		public var quantizeHPosition:Boolean;
		public var quantizeVPosition:Boolean;
		
		private var co:ContainerObject;
		private var spX:DragProperties;
		private var spY:DragProperties;
		private var tweenObject:Object;
		private var _width:Number;
		private var _height:Number;
		private var dragPoint:Point;
		private var onPositionUpdate:Function;
		private var objectDragging:*;
		
		public static const FORWARD:int = 1;
		
		public function DragController(containerObject:ContainerObject) 
		{
			co = containerObject;
			init();
		}
		
		public function set width(n:Number):void
		{
			_width = n;
		}
		
		public function set height(n:Number):void
		{
			_height = n;
		}
		
		public function contentChanged(dragItem:ContainerObject, fullBounds:Rectangle, pOnPositionUpdate:Function):void
		{
			onPositionUpdate = pOnPositionUpdate;
			setDragProperties(spX, fullBounds.width, _width, dragItem.width, quantizeHPosition, edgeElastisityH);
			setDragProperties(spY, fullBounds.height, _height, dragItem.height, quantizeVPosition, edgeElastisityV);	
		}
	
		public function get dragX():Number
		{
			return dragPoint.x;
		}
		
		public function set dragX(n:Number):void
		{
			dragPoint.x = n;
			onPositionUpdate(dragPoint);
		}
		
		public function set dragXPercent(n:Number):void
		{
			if (n < 0 || n > 1)
				return;
			else
				dragX = spX.dragSize * n;
		}
		
		public function get dragY():Number
		{
			return dragPoint.y;
		}
		
		public function set dragY(n:Number):void
		{
			dragPoint.y = n;
			onPositionUpdate(dragPoint);
		}
		
		public function set dragYPercent(n:Number):void
		{
			if (n < 0 || n > 1)
				return;
			else
				dragY = n * spY.dragSize;
		}
		
		public function dispose():void
		{
			removeListeners();
		}
		
		// PROTECTED METHODS
		
		protected function init():void
		{
			dragPoint = new Point();
			tweenObject = new Object();
			spX = new DragProperties;
			spY = new DragProperties;
			spX.setCurPos = function(n:Number):void { dragX = n; } 
			spX.getCurPos = function():Number { return dragX; }
			spY.setCurPos = function(n:Number):void { dragY = n; } 
			spY.getCurPos = function():Number { return dragY; }
			addListeners();
		}
		
		protected function setDragProperties(sp:DragProperties, 
							fullBoundsSize:int, dragSize:int, itemSize:int, quantizePosition:Boolean, edgeElastisity:Number):void
		{
			if (fullBoundsSize > dragSize)
			{
				sp.dragingEnabled = true;
				sp.elasticMinPos = dragSize * edgeElastisity * -1;
				sp.elasticMaxPos = fullBoundsSize - (dragSize * (1 - edgeElastisity));
				sp.fullBoundsSize = fullBoundsSize;
				sp.dragSize = dragSize;
				sp.itemSize = itemSize;
				sp.itemsPerPage = dragSize / sp.itemSize;
				if (sp.itemSize <= sp.dragSize)
					sp.quantizePosition = quantizePosition;
			}
			else
			{
				sp.atDragLimit = true;
				sp.dragingEnabled = false;
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
			TweenMax.killTweensOf(dragPoint);
			spX.downPos = co.mouseX;
			spY.downPos = co.mouseY;
			objectDragging = me.target;
			co.addEventListener(Event.ENTER_FRAME, measureVelocity);
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);	
		}
		
		protected function onMove(me:MouseEvent):void
		{
			if (spX.dragingEnabled)
				spX.setCurPos(drag(co.mouseX, spX)); 
			
			if (spY.dragingEnabled)	
				spY.setCurPos(drag(co.mouseY, spY)); 
			
			me.updateAfterEvent();
		}
		
		protected function drag(mousePos:Number, sp:DragProperties):int
		{
			var dragToPos:Number;
			var offset:Number;
			
			offset = mousePos - sp.downPos;

			dragToPos = sp.getCurPos() - offset;
			
			if (dragToPos + sp.overDragLimit > sp.elasticMaxPos)
			{
					dragToPos = sp.elasticMaxPos;
					sp.atDragLimit = true;
			}
			else if (dragToPos + sp.overDragLimit < sp.elasticMinPos)
			{
					dragToPos = sp.elasticMinPos;
					sp.atDragLimit = true;
			}
			else
			{
				sp.atDragLimit = false;
				dragToPos += calcSlip(sp, dragToPos);
			}
			return dragToPos;
		}
		
		protected function calcSlip(sp:DragProperties, dragToPos:Number):Number
		{
			var overDragLimit:int;

			if (dragToPos < 0)
				sp.overDragLimit = Math.abs(dragToPos);

			else if (dragToPos + sp.dragSize > sp.fullBoundsSize)
			{
				sp.overDragLimit = sp.fullBoundsSize - sp.dragSize - dragToPos;
			}
			overDragLimit += sp.overDragLimit * slipFactor;
			sp.overDragLimit = overDragLimit;
			return overDragLimit;
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
			spX.overDragLimit = spY.overDragLimit = 0;
			adjustPosition();
		}
		
		protected function doTween(seconds:Number):void
		{
			TweenMax.to(dragPoint, seconds, tweenObject);	
		}
		
		protected function onTweenUpdate():void
		{
			onPositionUpdate(dragPoint);
		}
		
		protected function adjustPosition():void
		{
			if (!spX.atDragLimit || !spY.atDragLimit)
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
		
		protected function getUpdatedPosition(sp:DragProperties):int
		{
			var updatedPos:Number;
			var dir:Number;
			
			if (sp.atDragLimit)
				updatedPos = sp.getCurPos();
			else if (!sp.quantizePosition)
				updatedPos = sp.getCurPos() - sp.velocity;
			else	
			{				
				dir = sp.direction * -1;
				updatedPos = sp.getCurPos() - sp.velocity - (sp.itemSize * 0.5  * sp.direction * dir);
				updatedPos += updatedPos / sp.itemSize;
				updatedPos -= updatedPos % (sp.dragSize / sp.itemsPerPage);
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
				TweenMax.killTweensOf(dragPoint);
				tweenObject.onUpdate = onTweenUpdate;
				tweenObject.ease = ease;
				tweenObject.onComplete = null;
				doTween(resetEaseSeconds);
			}
		}			
		
		protected function getResetPositionIfStretchingEdge(sp:DragProperties):Number
		{
			var resetPos:Number;
			var curPos:Number;
		
			curPos = resetPos = sp.getCurPos();
			if (sp.dragingEnabled  && curPos)
			{
				if (curPos < 0)
					resetPos = 0;
				else if (curPos + sp.dragSize > sp.fullBoundsSize)
					resetPos = sp.fullBoundsSize - sp.dragSize;
			}
			return resetPos;
		}
	}
}