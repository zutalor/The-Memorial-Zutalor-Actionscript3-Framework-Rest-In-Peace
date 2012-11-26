package com.zutalor.components.group 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ComponentGroupProperties extends PropertiesBase implements IProperties
	{	
		public var componentIds:String;
		public var viewItemTypes:String;
		public var numComponents:int;
		public var numCols:int;
		public var hPad:int;
		public var vPad:int;
		public var maxHaveValue:int;
		public var minHaveValue:int;		
	}
}