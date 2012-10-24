package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class UIProperties extends PropertiesBase implements IProperties
	{
		public var width:uint;
		public var height:uint;
		public var linestyle:uint;
		public var upColor:uint;
		public var overColor:uint;
		public var downColor:uint;
		public var backgroundColor:uint;
		public var backgroundAlpha:uint;
		public var cornerRounding:uint;
	}
}