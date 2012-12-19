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
		public var lastPos:int;
		public var velocity:Number;
		public var scrollSize:int;
		public var itemSize:int;
		public var itemsPerPage:int;
		public var quantizePosition:Boolean;		
		public var overScrollLimit:int;
		public var atScrollLimit:Boolean;
		public var elasticMinPos:int;
		public var elasticMaxPos:int;
		public var fullBoundsSize:int;
		
		private static var dir:int;
		
		public function get direction():int
		{
			if (velocity < 0)
				dir = -1;
			else if (velocity)
				dir = 1;	
				
			return dir;	
		}		
	}	
}