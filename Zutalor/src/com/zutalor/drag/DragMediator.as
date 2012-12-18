package com.zutalor.drag 
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.utils.gDictionary;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DragMediator 
	{
		protected var dragController:DragController():void
		private var object:gDictionary;
		private var co:ContainerObject;
		
		public function DragMediator(pCo:ContainerObject) 
		{
			co = pCo;
			init();
		}
		
		protected function init():void
		{
			dragController = new DragController(co)
		}
		
		public function registerObject(co:ContainerObject):void
		{
			
		}
		
	}

}