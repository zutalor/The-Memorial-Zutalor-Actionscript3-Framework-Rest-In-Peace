package com.zutalor.filters 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class FiltersItemProperties extends PropertiesBase implements IProperties
	{
		public function FiltersItemProperties () { }
		
		public var type:String;
		public var preset:String;
	}
}