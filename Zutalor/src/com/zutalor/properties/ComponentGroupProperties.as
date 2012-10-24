package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ComponentGroupProperties extends PropertiesBase implements IProperties
	{	
		public var componentIds:String;
		public var componentTypes:String;
		public var numComponents:int;
		public var numCols:int;
		public var hPad:int;
		public var vPad:int;
		public var maxHaveValue:int;
		public var minHaveValue:int;		
	}
}