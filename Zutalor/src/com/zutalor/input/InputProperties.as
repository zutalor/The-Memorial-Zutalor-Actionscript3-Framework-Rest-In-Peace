package com.zutalor.input 
{
	/**
	 * ...
	 * @author Geoff
	 */
	public class InputProperties
	{
		public var target:*;
		public var gesture:*;
		public var callback:*;
		public var listeners:Array;
		
		public function InputProperties()
		{
			listeners = [];
		}
	}
}