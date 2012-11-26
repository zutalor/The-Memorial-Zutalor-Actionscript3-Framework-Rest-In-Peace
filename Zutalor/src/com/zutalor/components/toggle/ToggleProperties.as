package com.zutalor.components.toggle 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
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