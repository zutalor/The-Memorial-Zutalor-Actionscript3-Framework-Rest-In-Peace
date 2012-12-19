package com.zutalor.containers 
{
	import com.zutalor.containers.Container;
	import com.zutalor.containers.positioning.Scroller;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ScrollingContainer extends Container
	{
		public var scroller:Scroller;
		private var _scrollRect:Rectangle;
		
		public function ScrollingContainer(name:String) 
		{
			super(name);
			_scrollRect = new Rectangle;
			scrollRect = _scrollRect;

			scroller = new Scroller(this, onPositionUpdate);
		}
		
		override public function set width(n:Number):void
		{
			_scrollRect.width = n;
			scrollRect = _scrollRect;
		}
		
		override public function set height(n:Number):void
		{
			_scrollRect.height = n;
			scrollRect = _scrollRect;
		}
		
		override public function dispose():void
		{
			super.dispose();
			scroller.dispose();
		}
		
		protected function onPositionUpdate(p:Point, o:*):void
		{
			_scrollRect.x = p.x;
			_scrollRect.y = p.y;
			scrollRect = _scrollRect;
		}
	}
}