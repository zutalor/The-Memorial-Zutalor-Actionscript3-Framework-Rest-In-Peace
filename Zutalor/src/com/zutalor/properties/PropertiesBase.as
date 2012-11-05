package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class PropertiesBase implements IProperties
	{
		public var child:PropertyManager;
		public var name:String;
		
		public function parseXML(xml:XML):Boolean
		{	
			MapXML.attributesToClass(xml , this); // map the properties
			name = name.toLowerCase();
			return true;
		}
	}
}