package com.zutalor.containers
{
	import com.zutalor.containers.utils.ViewContainerAligner;
	import com.zutalor.interfaces.IViewObject;
	import com.zutalor.events.ContainerEvent;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.controller.ViewController;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewContainer extends Container implements IViewObject
	{
		public var viewController:ViewController;
		public var viewContainerAligner:ViewContainerAligner;
				
		public function ViewContainer(containerName:String) 
		{
			super(containerName);
			viewContainerAligner = new ViewContainerAligner();
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
		
		public function alignContainer():void
		{
			viewContainerAligner.align(viewController.vp);
		}
		
		public function contentChanged(ev:ContainerEvent = null):void
		{
		}			
		
	}
}