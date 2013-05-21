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
		private var _width:Number;
		private var _height:Number;
		
		public var viewController:ViewController;
		
		public function ViewContainer(containerName:String)
		{
			super(containerName);
			viewController = new ViewController();
		}
				
		override public function stop(fadeSeconds:Number = 0):void
		{
			if (viewController)
				viewController.stop();
		}
		
		override public function dispose():void
		{
			if (viewController)
			{
				super.dispose();
				viewController.dispose();
				viewController = null;
			}
		}
	}
}