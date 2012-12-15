package com.zutalor.containers.scrolling 
{
	import com.greensock.easing.Quint;
	import com.greensock.TweenMax;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.events.UIEvent;
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
		public var flickEaseSeconds:Number = .5;
		public var OverEdgeEaseSeconds:Number = .75;
		public var minFlickVelocity:int = Capabilities.screenDPI / 4;
	
		protected var fullBoundsWidth:Number;
		protected var fullBoundsHeight:Number;
		protected var scrollRect:Rectangle;
		protected var sc:ScrollingContainer;
		
		public var spX:ScrollProperties;
		public var spY:ScrollProperties;
		
		public function ScrollController(scrollingContainer:ScrollingContainer) 
		{
			sc = scrollingContainer;
			init();
		}
		
		protected function init():void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onUp, false, 0, true);
			sc.addEventListener(MouseEvent.MOUSE_DOWN, onDown, false, 0, true);

			scrollRect = new Rectangle();
			spX = new ScrollProperties;
			spY = new ScrollProperties;
			
			spX.setPos = setScrollX;
			spX.getPos = getScrollY;
			spY.setPos = setScrollY;
			spY.getPos = getScrollY;
		}
		
		public function set scrollWidth(w:int):void
		{
			scrollRect.width = w;
		}
		
		public function set scrollHeight(h:int):void
		{
			scrollRect.height = h;
		}
		
		public function contentChanged():void
		{
			var r:Rectangle;
			var listItem:ContainerObject;
			
			if (sc.numChildren == 0)
			{
				scrollPercentX = 0;
				scrollPercentY = 0;
			}
			
			r = getFullBounds(sc);
			fullBoundsWidth = r.width;
			fullBoundsHeight = r.height;
			
			listItem = sc.getChildAt(0) as ContainerObject;
			
			spX.midPos = scrollRect.width / 2;
			spX.minPos = spX.midPos * -1;
			spX.maxPos = fullBoundsWidth - spX.midPos;
			spX.range = fullBoundsWidth;
			spX.itemSize = listItem.width;
			spX.itemsPerPage = sc.width / spX.itemSize;

			spY.midPos = scrollRect.height / 2;
			spY.minPos = spY.midPos * -1;
			spY.maxPos = fullBoundsHeight - spY.midPos;
			spY.range = fullBoundsHeight;
			spY.itemSize = listItem.height;
			spY.itemsPerPage = sc.height / listItem.height;
			
			if (fullBoundsWidth > sc.width)
				spX.scrollEnabled = true;
			else
				spX.scrollEnabled = true;
			
			if (fullBoundsHeight > sc.height)
				spY.scrollEnabled = true;
			else
				spY.scrollEnabled = true;
				
			scrollRect.height = sc.height;
			scrollRect.width = sc.width;
		}
		
		public function dispose():void
		{
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			sc.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		protected function onDown(me:Event):void
		{
		    spX.downPos = sc.mouseX;
			spY.downPos = sc.mouseY;
			addEventListener(Event.ENTER_FRAME, measureVelocity, false, 0, true);
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove, false, 0, true);	
		}
		
		protected function onMove(me:MouseEvent):void
		{
			spX.setPos(adjustEdge(sc.mouseX, spX)); 
			spY.setPos(adjustEdge(sc.mouseY, spY)); 
			me.updateAfterEvent();
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
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);	
			if (spX.velocity < minFlickVelocity && spY.velocity < minFlickVelocity)
				dispatchEvent(new UIEvent(UIEvent.TAP));
			else
				flick();
		}
		
		protected function flick():void
		{			
			if (spX.scrollEnabled && !spX.overEdge && spX.velocity > minFlickVelocity)
			{	
				spX.tweenObject = new Object();
				spX.tweenObject.onUpdate = onTween;
				spX.tweenObject.x = getFlickPos(spX);
				spX.tweenObject.ease = ease;
				tweenFlick(spX)
			}
			
			if (spY.scrollEnabled && !spY.overEdge && spY.velocity > minFlickVelocity)
			{
				spY.tweenObject = new Object();
				spY.tweenObject.onUpdate = onTween;
				spY.tweenObject.y = getFlickPos(spY);
				spY.tweenObject.ease = ease;
				spY.tweenObject.onComplete = conformBounds;
				tweenFlick(spY);
			}
			MasterClock.callOnce(conformBounds, flickEaseSeconds * 1000);
		}
		
		protected function getFlickPos(sp:ScrollProperties):int
		{
			var newPos:int;
			
			newPos = sp.getPos() - sp.velocity - (sp.itemSize * 0.5  * sp.direction);
			newPos += newPos / sp.itemSize;
			newPos -= newPos % (sp.range / sp.itemsPerPage);
			return newPos;
		}
		
		protected function tweenFlick(sp:ScrollProperties):void
		{	
			TweenMax.to(scrollRect, flickEaseSeconds, sp.tweenObject );	
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
				if (scrollRect.x < 0)
					TweenMax.to(scrollRect, OverEdgeEaseSeconds, { x:0, onUpdate:onTween, ease:ease } );
				else if (scrollRect.x + sc.width > fullBoundsWidth)
					TweenMax.to(scrollRect, OverEdgeEaseSeconds, { x:fullBoundsWidth - sc.width, onUpdate:onTween, ease:ease } );
			}
			
			if (spY.scrollEnabled)
			{
				if (scrollRect.y < 0)
					TweenMax.to(scrollRect, OverEdgeEaseSeconds, { y:0, onUpdate:onTween, ease:ease } );
				else if (scrollRect.y + sc.height > fullBoundsHeight)
					TweenMax.to(scrollRect, OverEdgeEaseSeconds, { y:fullBoundsHeight - sc.height, onUpdate:onTween, ease:ease } );
			}	
		}
		
		protected function onTween():void
		{
			sc.scrollRect = scrollRect;
		}
		
		public function getScrollX():Number
		{
			return scrollRect.x;
		}
		
		public function setScrollX(n:Number):void
		{
			scrollRect.x = n;
			sc.scrollRect = scrollRect;
		}
		
		public function getScrollY():Number
		{
			return scrollRect.y;
		}
		
		public function setScrollY(n:Number):void
		{
			scrollRect.y = n;
			sc.scrollRect = scrollRect;
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