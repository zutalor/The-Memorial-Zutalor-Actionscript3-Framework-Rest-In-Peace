package com.zutalor.filters 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.properties.PropertyManager;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class FiltersProperties extends PropertiesBase implements IProperties
	{
		public function FiltersProperties() { }
		
		public var filterPresetsItemProperties:PropertyManager;				
	}
}