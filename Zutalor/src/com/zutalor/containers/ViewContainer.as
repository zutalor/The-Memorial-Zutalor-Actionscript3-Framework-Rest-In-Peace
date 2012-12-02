package com.zutalor.containers
{
	import adobe.utils.CustomActions;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.components.Component;
	import com.zutalor.events.ContainerEvent;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.propertyManagers.Presets;
	import com.zutalor.ui.Focus;
	import com.zutalor.utils.DisplayObjectUtils;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.controller.ViewController;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewContainer extends Container implements IDisposable
	{
		public var viewController:ViewController;
				
		public function ViewContainer(containerName:String) 
		{
			super(containerName);
		}
		
		public function callContainerMethod(method:String, params:String):void
		{
			
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