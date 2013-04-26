package com.zutalor.containers
{
	import com.zutalor.interfaces.IContainerObject;
	import com.zutalor.positioning.Arranger;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.controller.ViewController;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewContainer extends Container implements IContainerObject
	{
		public var viewController:ViewController;
		public var arranger:Arranger;
				
		public function ViewContainer(containerName:String)
		{
			super(containerName);
			arranger = new Arranger(this);
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
		
		override public function contentChanged():void
		{
		}
		
		override public function dispose():void
		{
			super.dispose();
			viewController.dispose();
		}
	}
}