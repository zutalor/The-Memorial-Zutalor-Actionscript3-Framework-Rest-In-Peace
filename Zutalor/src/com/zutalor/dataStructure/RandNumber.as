package com.zutalor.dataStructure
{
	import com.zutalor.utils.MathG;
	/**
	 * ...
	 * @author Geoff
	 */
	public class RandNumber
	{
		public var min:Number;
		public var max:Number;
		
		public function RandNumber(min:Number,max:Number)
		{
			this.min = min;
			this.max = max;
		}
		
		public function get value():Number
		{
			return MathG.randFloat(min, max);
		}
	}
}