package com.zutalor.properties  
{
	import com.zutalor.interfaces.IProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class GlowFilterProperties extends PropertiesBase implements IProperties
	{
		public var color:uint;
		public var alpha:Number;
		public var blurX:Number;
		public var blurY:Number;
		public var strength:Number;
		public var quality:Number;
		public var inner:Boolean;
		public var knockout:Boolean;
	}
}