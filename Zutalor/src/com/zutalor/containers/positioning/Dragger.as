package com.zutalor.containers.positioning 
{
	import com.greensock.TweenMax;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.positioning.base.Positioner;
	import com.zutalor.containers.positioning.base.PositionProperties;
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
		private var objects:gDictionary;
		private var co:ContainerObject;
		
		public function Dragger(co:ContainerObject, onPositionUpdate:Function)
		{
			super(co, onPositionUpdate);
		}
		
		public function registerObject(co:ContainerObject):void
		{
		}
		
		override protected function getPosition(mousePos:Number, pp:PositionProperties):int
		{
			if (!pp.offset)
				pp.offset = pp.targetPos;

			return mousePos - pp.offset;	
		}
		
		override protected function onUp(me:Event):void
		{
			ppX.offset = ppY.offset = 0;
			super.onUp(me);
		}
		
		override protected function applyBalistics(pp:PositionProperties):int
		{
			return pp.getCurPos() + pp.velocity;;
		}
		
		override public function dispose():void
		{
			if (objects)
				objects.dispose();
				
			objects = null;
		}
	}
}