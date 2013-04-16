package com.zutalor.dataStructure
{
	import com.zutalor.utils.MathG;
	/**
	 * ...
	 * @author Geoff
	 */
	public class RandInt
	{
		public var min:int;
		public var max:int;
		
		public function Randint(min:int,max:int)
		{
			this.min = min;
			this.max = max;
		}
		
		public function get value():int
		{
			return MathG.rand(min, max);
		}
	}
}