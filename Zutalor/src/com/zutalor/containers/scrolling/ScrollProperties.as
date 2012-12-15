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
		public var enableScroll:Boolean;
		public var downPos:int;
		public var velocity:int;
		public var lastPos:int;
		public var overEdge:Boolean;
		public var midPos:int;
		public var minPos:int;
		public var maxPos:int;
		
		public function get direction():int
		{
			if (velocity <= 0)
				return -1;
			else if (velocity)
				return 1;
		}
	}	
}