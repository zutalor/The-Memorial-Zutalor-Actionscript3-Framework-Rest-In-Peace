package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MotionProperties extends PropertiesBase implements IProperties
	{
		public var viewName:String;
		public var scrollPercentX:Number;
		public var scrollTimeX:Number;
		public var scrollPercentY:Number;
		public var scrollTimeY:Number;
	}
}