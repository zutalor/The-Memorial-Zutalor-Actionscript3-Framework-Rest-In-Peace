package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ToggleProperties extends PropertiesBase implements IProperties
	{	
		public var onStateButtonId:String;
		public var offStateButtonId:String;
		public var initialValue:Boolean;
	}
}