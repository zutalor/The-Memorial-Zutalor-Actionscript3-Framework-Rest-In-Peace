package com.zutalor.positioning.base
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
	public class Positioner extends EventDispatcher
	{
		
		public static const FORWARD:int = 1;
		public static const BACKWARD:int = -1;

		public var velocityMultiplier:Number = 1;
		public var tapPossible:Boolean = true;
		public var ease:Function = Quint.easeOut;
		public var easeSeconds:Number = .5;
		public var resetEaseSeconds:Number = .75;
		public var slipFactor:Number = 0;
		public var edgeElastisityH:Number = .5;
		public var edgeElastisityV:Number = 0.5;
		public var quantizeHPosition:Boolean;
		public var quantizeVPosition:Boolean;
		public var onPositionUpdate:Function;
		public var target:*;
				
		protected var ppX:PositionProperties;
		protected var ppY:PositionProperties;
		
		public var co:ContainerObject;
		
		private var tweenObject:Object;
		private var _width:Number;
		private var _height:Number;
		private var _direction:int;
		private var position:Point;		
		
		public function Positioner(containerObject:ContainerObject, onPositionUpdate:Function)
		{
			co = containerObject;
			this.onPositionUpdate = onPositionUpdate;
			init();
		}
		
		public function initialize(fullBoundsWidth:int, fullBoundsHeight:int, ViewportWidth:int, ViewportHeight:int, itemWidth:int=0, itemHeight:int=0):void
		{
			setPositionProperties(ppX, fullBoundsWidth, ViewportWidth, itemWidth, quantizeHPosition, edgeElastisityH);
			setPositionProperties(ppY, fullBoundsHeight, ViewportHeight, itemHeight, quantizeVPosition, edgeElastisityV);
			addListeners();
		}
		
		public function set direction(d:int):void
		{
			_direction = d;
			if (d > 0)
				ppX.reverseDirection = ppY.reverseDirection = true;
			else
				ppX.reverseDirection = ppY.reverseDirection = true;
		}
		
		public function get direction():int
		{
			return _direction;
		}
		
		public function get xPos():Number
		{
			return position.x;
		}
		
		public function set xPos(n:Number):void
		{
			position.x = n;
			onPositionUpdate(position, target);
		}
		
		public function set xPosPercent(n:Number):void
		{
			if (n < 0 || n > 1)
				return;
			else
				xPos = ppX.ViewportSize * n;
		}
		
		public function get yPos():Number
		{
			return position.y;
		}
		
		public function set yPos(n:Number):void
		{
			position.y = n;
			onPositionUpdate(position, target);
		}
		
		public function set yPosPercent(n:Number):void
		{
			if (n < 0 || n > 1)
				return;
			else
				yPos = n * ppY.ViewportSize;
		}
		
		public function dispose():void
		{
			removeListeners();
		}
		
		// PROTECTED METHODS
		
		protected function init():void
		{
			position = new Point();
			tweenObject = new Object();
			ppX = new PositionProperties;
			ppY = new PositionProperties;
			direction = FORWARD;
			ppX.setCurPos = function(n:Number):void { xPos = n; }
			ppX.getCurPos = function():Number { return xPos }
			ppY.setCurPos = function(n:Number):void { yPos = n }
			ppY.getCurPos = function():Number { return yPos; }
			addListeners();
		}
		
		protected function setPositionProperties(pp:PositionProperties, fullBoundsSize:int, ViewportSize:int, 
														itemSize:int, quantizePosition:Boolean, edgeElastisity:Number):void
		{
			pp.positioningEnabled = true;
			pp.fullBoundsSize = fullBoundsSize;
			pp.ViewportSize = ViewportSize;
			pp.itemSize = itemSize;
		}
		
		protected function addListeners():void
		{
			co.addEventListener(MouseEvent.MOUSE_UP, onUp);
			co.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		protected function removeListeners():void
		{
			co.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			co.removeEventListener(MouseEvent.MOUSE_OUT, onUp);
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			co.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		protected function onDown(me:MouseEvent):void
		{
			TweenMax.killTweensOf(position);
			tapPossible = true;
			ppX.downPos = co.mouseX;
			ppY.downPos = co.mouseY;
			target = me.target;
			ppY.targetScale = me.target.scaleY;
			ppX.targetScale = me.target.scaleX;
			ppX.targetPos = me.target.mouseX;
			ppY.targetPos = me.target.mouseY;
			co.addEventListener(Event.ENTER_FRAME, measureVelocity);
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		}
		
		protected function onMove(me:MouseEvent):void
		{
			tapPossible = false;
			if (ppX.positioningEnabled)
				ppX.setCurPos(getPosition(co.mouseX, ppX));
			
			if (ppY.positioningEnabled)
				ppY.setCurPos(getPosition(co.mouseY, ppY));
			
			me.updateAfterEvent();
		}
		
		protected function onUp(me:MouseEvent):void
		{
			co.removeEventListener(Event.ENTER_FRAME, measureVelocity);
			co.removeEventListener(MouseEvent.MOUSE_OUT, onUp);
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			ppX.overViewportEdge = ppY.overViewportEdge = 0;
			ppX.offset = ppY.offset = 0;
			checkForTap();
		}
		
		protected function checkForTap():void
		{
			if (tapPossible && !ppX.velocity && !ppY.velocity)
			{
	
				//dispatchEvent( new UIEvent(UIEvent.TAP));
				trace("click", target);
			}
			else
				moveToPosition();
		}
		
		protected function moveToPosition():void
		{
			if (!ppX.atViewportEdge || !ppY.atViewportEdge)
			{
				tweenObject.x = applyBalistics(ppX);
				tweenObject.y = applyBalistics(ppY);
				tweenObject.ease = ease;
				tweenObject.onUpdate = onTweenUpdate;
				tweenObject.onComplete = resetAfterMoveIfNeeded;
				doTween(easeSeconds);
			}
			else
				resetAfterMoveIfNeeded();
		}
		
		protected function resetAfterMoveIfNeeded():void
		{
			var oldX:int;
			var oldY:int;
			
			oldX = ppX.getCurPos();
			oldY = ppY.getCurPos();
			
			tweenObject.x = getResetPosition(ppX);
			tweenObject.y = getResetPosition(ppY);
			
			if (tweenObject.x != oldX || tweenObject.y != oldY)
			{
				TweenMax.killTweensOf(position);
				tweenObject.onUpdate = onTweenUpdate;
				tweenObject.ease = ease;
				tweenObject.onComplete = null;
				doTween(resetEaseSeconds);
			}
		}
		
		//Position Adjusters
		
		protected function getPosition(mousePos:Number, pp:PositionProperties):int
		{ 
			return mousePos;
		}	
		
		protected function applyBalistics(pp:PositionProperties):int
		{
			return pp.getCurPos() + pp.velocity * velocityMultiplier;
		}
		
		protected function getResetPosition(pp:PositionProperties):Number
		{
			return pp.getCurPos();
		}
		
		protected function doTween(seconds:Number):void
		{
			TweenMax.to(position, seconds, tweenObject);
		}
		
		protected function onTweenUpdate():void
		{
			onPositionUpdate(position, target);
		}
		
		protected function measureVelocity(e:Event):void
		{
			ppX.velocity = (StageRef.stage.mouseX - ppX.lastPos) * direction;
			ppY.velocity = (StageRef.stage.mouseY - ppY.lastPos) * direction;
			ppX.lastPos = StageRef.stage.mouseX;
			ppY.lastPos = StageRef.stage.mouseY;
		}
	}
}