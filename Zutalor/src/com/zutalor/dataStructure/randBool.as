package com.zutalor.dataStructure
{
	/**
	 * ...
	 * @author Geoff
	 */
	public class RandBool
	{
		
		public function RandBool()
		{
			
		}
		
		public function get value():Boolean
		{
			return MathG.rand(0,1) == 1;
		}
	}
}