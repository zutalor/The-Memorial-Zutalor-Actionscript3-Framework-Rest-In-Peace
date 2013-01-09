package com.zutalor.filters.base  
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class FuzzyFilterProperties extends PropertiesBase implements IProperties
	{
		public function FuzzyFilterProperties() {}
		
		public var color:uint;
		public var alpha:Number;
		public var blurX:Number;
		public var blurY:Number;
		public var strength:Number;
		public var distance:Number;
		public var angle:Number;
		public var quality:Number;
		public var inner:Boolean;
		public var knockout:Boolean;
	}
}