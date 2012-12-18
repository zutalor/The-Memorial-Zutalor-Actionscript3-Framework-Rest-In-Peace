package com.zutalor.drag 
{
	/**
	 * ...
	 * @author Geoff
	 */
	public class DragProperties 
	{
		public var setCurPos:Function;
		public var getCurPos:Function;
		public var dragingEnabled:Boolean;
		public var downPos:int;
		public var lastPos:int;
		public var velocity:Number;
		public var dragSize:int;
		public var itemSize:int;
		public var itemsPerPage:int;
		public var quantizePosition:Boolean;		
		public var overDragLimit:int;
		public var atDragLimit:Boolean;
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