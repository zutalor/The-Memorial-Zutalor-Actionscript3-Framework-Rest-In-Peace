package com.zutalor.containers.scrolling 
{
	import com.zutalor.containers.Container;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ScrollingContainer extends Container
	{
		public var scrollController:ScrollController;
		
		public function ScrollingContainer(name:String) 
		{
			super(name);
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