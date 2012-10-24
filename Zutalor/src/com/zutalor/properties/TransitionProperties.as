package com.zutalor.properties  
{
	import com.greensock.easing.Quint;
	import com.zutalor.fx.Easing;
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TransitionProperties extends PropertiesBase implements IProperties
	{
		public var inType:String;
		public var inEaseType:String;
		public var inEase:Function;
		public var inTime:Number;
		public var inDelay:Number;
		public var outType:String;
		public var outEaseType:String;
		public var outEase:Function;
		public var outTime:Number;
		public var outDelay:Number;	
		public var xValue:Number;
		public var yValue:Number;
				
		override public function parseXML(xml:XML):Boolean
		{	
			MapXML.attributeToClass(xml , this); // map the properties
			name = name.toLowerCase();			

			inEase = Easing.getEase(inEaseType);
			outEase = Easing.getEase(outEaseType);
				
			return true;
		}
	}
}