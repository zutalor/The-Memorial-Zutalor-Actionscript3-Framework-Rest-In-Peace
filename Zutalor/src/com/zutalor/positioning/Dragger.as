package com.zutalor.positioning 
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.positioning.base.Positioner;
	import com.zutalor.positioning.base.PositionProperties;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Dragger extends Positioner
	{
		public function Dragger(co:ContainerObject, onPositionUpdate:Function)
		{
			super(co, onPositionUpdate);
			velocityMultiplier = 2;
		}
		
		override protected function onDown(me:MouseEvent):void
		{
			me.target.parent.addChild(me.target);
			super.onDown(me);
		}
			
		override protected function getPosition(mousePos:Number, pp:PositionProperties):int
		{
			if (!pp.offset)
				pp.offset = pp.targetPos;

			return mousePos - pp.offset * pp.targetScale;	
		}
	}
}