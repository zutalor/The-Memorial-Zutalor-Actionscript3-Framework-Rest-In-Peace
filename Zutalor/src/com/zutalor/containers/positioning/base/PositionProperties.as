package com.zutalor.containers.positioning.base 
{
	/**
	 * ...
	 * @author Geoff
	 */
	public class PositionProperties 
	{
		public var setCurPos:Function;
		public var getCurPos:Function;
		public var positioningEnabled:Boolean;
		public var downPos:int;
		public var lastPos:int;
		public var targetPos:int;
		public var offset:int;
		public var targetScale:Number;
		public var velocity:Number;
		public var ViewportSize:int;
		public var itemSize:int;
		
		public var quantizePosition:Boolean;		
		public var overViewportEdge:int;
		public var atViewportEdge:Boolean;
		public var elasticMinPos:int;
		public var elasticMaxPos:int;
		public var fullBoundsSize:int;
		
		public var reverseDirection:Boolean;
		public var itemsPerPage:int;
		
		private static var dir:int;
		
		public function get direction():int
		{
			if (velocity < 0)
				dir = -1;
			else if (velocity)
				dir = 1;	
				
			if (reverseDirection)
				dir *= -1;
				
			return dir;	
		}		
	}	
}