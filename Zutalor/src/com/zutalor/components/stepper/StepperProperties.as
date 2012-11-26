package com.zutalor.components.stepper 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class StepperProperties extends PropertiesBase implements IProperties
	{	
		public var type:String;
		public var upButtonId:String;
		public var downButtonId:String;
		public var backgroundId:String;
		public var increment:Number;
		public var precision:int;
		public var initialValue:Number;
		public var minValue:Number;
		public var maxValue:Number;
		public var vertical:Boolean;
		public var textAttributes:String;
	}
}