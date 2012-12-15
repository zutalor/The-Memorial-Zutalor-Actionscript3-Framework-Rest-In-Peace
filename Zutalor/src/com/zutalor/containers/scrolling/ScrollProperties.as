package com.zutalor.containers.scrolling 
{
	/**
	 * ...
	 * @author Geoff
	 */
	public class ScrollProperties 
	{
		public var setPos:Function;
		public var getPos:Function;
		public var scrollEnabled:Boolean;
		public var downPos:int;
		public var velocity:int;
		public var lastPos:int;
		public var overEdge:Boolean;
		public var midPos:int;
		public var minPos:int;
		public var maxPos:int;
		public var range:int;
		public var itemSize:int;
		public var itemsPerPage:int;
		public var tweenObject:Object;
		
		public function get direction():int
		{
			var dir:int;
			
			if (velocity <= 0)
				dir = -1;
			else if (velocity)
				dir = 1;
				
			return dir;	
		}
	}	
}