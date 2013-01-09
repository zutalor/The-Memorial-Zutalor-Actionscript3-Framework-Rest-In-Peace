package com.zutalor.components.graphic 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.properties.PropertyManager;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class GraphicProperties extends PropertiesBase implements IProperties
	{			
		public var graphicItemProperties:PropertyManager;
		public var maskId:String;
		public var maskX:int;
		public var maskY:int;
		public var autoOrient:Boolean = true;	
		public var lifeTime:Number;
		public var transitionIn:String;
		public var transitionOut:String;
		public var loop:Number; //-1 infinite
		public var loopDelay:Number;
		
		public function GraphicProperties() { }
	}
}