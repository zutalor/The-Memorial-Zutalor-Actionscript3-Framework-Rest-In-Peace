package depreciated 
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MaskedContainer extends ViewContainer
	{	
		private var _scrollRect:Rectangle;
		private var _scrollPercentX:Number;
		private var _scrollPercentY:Number;
		
		public function MaskedContainer(name:String)
		{
			super(name);
			_scrollRect = new Rectangle(0,0,30,30);
			scrollRect = _scrollRect;
		}
		
		override public function set width(n:Number):void
		{
			_scrollRect.width = width;
		}
		
		override public function set height(n:Number):void
		{
			_scrollRect.height = width;
		}
		
		
		override public function get width():Number
		{
			return _scrollRect.width * scaleX;
		}
				
		override public function get height():Number
		{
			return _scrollRect.height * scaleY;
		}		
								
		protected function get hScrollable():Boolean
		{
			if (_scrollRect.width >= width)
				return false;
			else
				return true;
		}
		
		protected function get vScrollable():Boolean
		{
			if (_scrollRect.height >= height)
				return false;
			else
				return true;
		}
								
		protected function get scrollRectWidth():Number
		{
			return _scrollRect.width;
		}
		
		protected function set scrollRectWidth(n:Number):void
		{
			_scrollRect.width = n;
		}
		
		protected function get scrollRectHeight():Number
		{
			return _scrollRect.height;
		}
		
		protected function set scrollRectHeight(n:Number):void
		{
			_scrollRect.height = n;
		}
		
		override public function set scrollPercentX(percent:Number):void
		{
			_scrollPercentX = percent;
			_scrollRect.x =  (width - _scrollRect.width) * _scrollPercentX;
			_scrollRect = _scrollRect; // Okay, we must apply the rectangle again to make scrolling work.			
		}
		
		override public function get scrollPercentX():Number
		{
			return _scrollPercentX;
		}
		
		override public function set scrollPercentY(percent:Number):void
		{
			_scrollPercentY = percent;
			_scrollRect.y =  (height - _scrollRect.height) * _scrollPercentY;
			_scrollRect = _scrollRect; // Okay, we must apply the rectangle again to make scrolling work.
		}
		
		override public function get scrollPercentY():Number
		{
			return _scrollPercentY;
		}		
	}
}