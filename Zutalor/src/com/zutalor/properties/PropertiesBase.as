package com.zutalor.properties
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class PropertiesBase implements IProperties
	{
		public var child:PropertyManager;
		public var name:String;
		public var ignoreCaseInKey:Boolean = true;
		
		public function PropertiesBase() {}
		
		public function parseXML(xml:XML):Boolean
		{
			MapXML.attributesToClass(xml , this);
			if (ignoreCaseInKey)
				name = name.toLowerCase();
			return true;
		}
	}
}