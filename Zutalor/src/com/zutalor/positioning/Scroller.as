package com.zutalor.positioning
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.positioning.base.Positioner;
	import com.zutalor.positioning.base.PositionProperties;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Scroller extends Positioner
	{
		
		public function Scroller(containerObject:ContainerObject, onPositionUpdate:Function)
		{
			slipFactor = .3;
			super(containerObject, onPositionUpdate);
		}
		
		override protected function setPositionProperties(pp:PositionProperties, fullBoundsSize:int, ViewportSize:int, 
														itemSize:int, quantizePosition:Boolean, edgeElastisity:Number):void
		{
			if (fullBoundsSize > ViewportSize)
			{
				pp.positioningEnabled = true;
				pp.elasticMinPos = ViewportSize * edgeElastisity * -1;
				pp.elasticMaxPos = fullBoundsSize - (ViewportSize * (1 - edgeElastisity));
				pp.fullBoundsSize = fullBoundsSize;
				pp.ViewportSize = ViewportSize;
				pp.itemSize = itemSize;
				pp.itemsPerPage = ViewportSize / pp.itemSize;
				if (pp.itemSize <= pp.ViewportSize)
					pp.quantizePosition = quantizePosition;
			}
			else
			{
				pp.atViewportEdge = true;
				pp.positioningEnabled = false;
			}
		}
		
		override protected function onDown(me:MouseEvent):void
		{
			super.onDown(me);
			//co.addEventListener(MouseEvent.MOUSE_OUT, onUp);
		}
		
		override protected function onUp(me:MouseEvent):void
		{
			super.onUp(me);
			co.removeEventListener(MouseEvent.MOUSE_OUT, onUp);
		}
		
		//Position Adjusters	
		
		override protected function getPosition(mousePos:Number, pp:PositionProperties):int
		{
			var pos:Number;
			var offset:Number;
			
			offset = mousePos - pp.downPos;
			pos = (pp.getCurPos() - offset) * direction;
		
			if (pos + pp.overViewportEdge > pp.elasticMaxPos)
			{
				pos = pp.elasticMaxPos;
				pp.atViewportEdge = true;
			}
			else if (pos + pp.overViewportEdge < pp.elasticMinPos)
			{
				pos = pp.elasticMinPos;
				pp.atViewportEdge = true;
			}
			else
			{
				pp.atViewportEdge = false;
				pos += adjustPositionForSlippage(pp, pos);
			}
			return pos;
		}
		
		protected function adjustPositionForSlippage(pp:PositionProperties, pos:Number):Number
		{
			var slipAdjustment:int;
			
			if (pos < 0)
				pp.overViewportEdge = Math.abs(pos);
			
			else if (pos + pp.ViewportSize > pp.fullBoundsSize)
			{
				pp.overViewportEdge = pp.fullBoundsSize - pp.ViewportSize - pos;
			}
			slipAdjustment += pp.overViewportEdge * slipFactor;
			pp.overViewportEdge = slipAdjustment;
			return slipAdjustment;
		}			
		
		override protected function applyBalistics(pp:PositionProperties):int
		{
			var updatedPos:Number;
			var dir:Number;
			
			if (pp.atViewportEdge)
				updatedPos = pp.getCurPos();
			else if (!pp.quantizePosition)
				updatedPos = pp.getCurPos() - pp.velocity;
			else
			{
				dir = pp.direction * -1;
				updatedPos = pp.getCurPos() - pp.velocity - (pp.itemSize * 0.5 * pp.direction * dir);
				updatedPos += updatedPos / pp.itemSize;
				updatedPos -= updatedPos % (pp.ViewportSize / pp.itemsPerPage);
			}
			return updatedPos;
		}
		
		override protected function getResetPosition(pp:PositionProperties):Number
		{
			var pos:Number;
			var curPos:Number;
			
			curPos = pos = pp.getCurPos();
			if (pp.positioningEnabled && curPos)
			{
				if (curPos < 0)
					pos = 0;
				else if (curPos + pp.ViewportSize > pp.fullBoundsSize)
					pos = pp.fullBoundsSize - pp.ViewportSize;
			}
			return pos;
		}
	}
}