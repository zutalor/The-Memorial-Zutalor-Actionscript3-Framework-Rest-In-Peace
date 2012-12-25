package com.zutalor.positioning 
{
	import com.greensock.TweenMax;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.positioning.base.Positioner;
	import com.zutalor.positioning.base.PositionProperties;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.StageRef;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
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
			
		override protected function getPosition(mousePos:Number, pp:PositionProperties):int
		{
			if (!pp.offset)
				pp.offset = pp.targetPos;

			return mousePos - pp.offset * pp.targetScale;	
		}
	}
}