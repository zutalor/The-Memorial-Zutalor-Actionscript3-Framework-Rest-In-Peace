package com.zutalor.containers
{
	import com.zutalor.interfaces.IContainerObject;
	import com.zutalor.events.ContainerEvent;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.controller.ViewController;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewContainer extends Container implements IContainerObject
	{
		public var viewController:ViewController;
				
		public function ViewContainer(containerName:String) 
		{
			super(containerName);
		}
		
		public function callViewItemMethod(viewItem:String, method:String, params:String):void
		{
			var item:*;
			//TODO check for more errors
			item = viewController.getItemByName(viewItem);
			if (item)
				item[method](params);
			else
				ShowError.fail(ViewContainer,viewItem + " not found on " + name);
		}
				
		override public function stop(fadeSeconds:Number = 0):void 
		{
			if (viewController)
				viewController.stop();
		}
				
		public function tweenScrollPercentY(percent:Number, tweenTime:Number = 0.5, ease:Function = null):void
		{
		}
				
		public function tweenScrollPercentX(percent:Number, tweenTime:Number=0.5, ease:Function=null):void
		{
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
		
		
		public function contentChanged(ev:ContainerEvent = null):void
		{
		}			
		
	}
}