package com.zutalor.gesture 
{
	/**
	 * ...
	 * @author Geoff
	 */
	public class GestureProperties
	{
		public var gestureId:*; //Key
		public var target:*; //Key
		
		public var gesture:*;	
		public var callback:*;
		public var listeners:Array;
		
		public function GestureProperties()
		{
			listeners = [];
		}
	}
}