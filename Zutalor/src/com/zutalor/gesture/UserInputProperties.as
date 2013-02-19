package com.zutalor.gesture
{
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class UserInputProperties extends PropertiesBase
	{	
		public var type:String;
		public var action:String;
		public var up:String;
		public var down:String;
		public var left:String;
		public var right:String;
		public var rows:int;
		public var cols:int;
		public var sound:String;
		
		public function UserInputProperties() { }
	}
}