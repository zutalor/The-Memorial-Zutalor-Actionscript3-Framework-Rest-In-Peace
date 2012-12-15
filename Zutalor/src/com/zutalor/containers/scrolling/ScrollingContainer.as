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
				
		override public function contentChanged():void
		{
			scrollController.contentChanged();
		}
		
		override public function dispose():void
		{
			super.dispose();
			scrollController.dispose();
		}
		
		public function contentInitialized():void
		{
			contentChanged();
		}
	}
}