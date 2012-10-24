package com.zutalor.properties  
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class DropShadowFilterProperties extends PropertiesBase implements IProperties
	{
		public var distance:Number;
		public var angle:Number;
		public var color:Number;
		public var alpha:Number;
		public var blurX:Number;
		public var blurY:Number;
		public var quality:Number;
	}
}