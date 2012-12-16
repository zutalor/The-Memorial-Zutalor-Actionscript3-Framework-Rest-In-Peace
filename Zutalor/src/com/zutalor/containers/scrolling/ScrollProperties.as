package com.zutalor.containers.scrolling 
{
	/**
	 * ...
	 * @author Geoff
	 */
	public class ScrollProperties 
	{
		public var setCurPos:Function;
		public var getCurPos:Function;
		public var scrollingEnabled:Boolean;
		public var downPos:int;
		public var velocity:Number;
		public var lastPos:int;
		public var atScrollLimit:Boolean;
		public var midPos:int;
		public var minPos:int;
		public var maxPos:int;
		public var fullBoundsSize:int;
		public var scrollSize:int;
		public var itemSize:int;
		public var itemsPerPage:int;
		public var quantizePosition:Boolean;
		
		public function get direction():int
		{
			var dir:int;
			
			if (velocity < 0)
				dir = -1;
			else
				dir = 1;	
				
			return dir;	
		}
	}	
}