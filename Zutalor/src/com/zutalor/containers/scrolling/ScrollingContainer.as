package com.zutalor.containers.scrolling 
{
	import com.zutalor.containers.ViewContainer;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ScrollingContainer extends ViewContainer 
	{	
		public var scrollController:ScrollController;
		
		public function ScrollingContainer(containerName:String) 
		{
			super(containerName);
			scrollController = new ScrollController(this);
		}
		
		override public function dispose():void
		{
			super.dispose();
			scrollController.dispose();
			scrollController = null;
		}
	}
}