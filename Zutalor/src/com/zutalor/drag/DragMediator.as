package com.zutalor.drag 
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.Scale;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DragMediator 
	{
		private var object:gDictionary;
		
		public function DragMediator(co:ContainerObject, width:int, height:int, edgeElastisity:Number = 2.25) 
		{
			var fullWidth:int;
			var fullHeight:int;
			
			fullHeight = height * edgeElastisity;
			fullWidth = width * edgeElastisity;
			
			
		}
		
		public function registerObject(co:ContainerObject):void
		{
		}
		
		protected function onPositionUpdate(p:Point, co:*):void
		{
			trace(p.y);
			co.x = p.x;
			co.y = p.y;
		}
		
	}

}