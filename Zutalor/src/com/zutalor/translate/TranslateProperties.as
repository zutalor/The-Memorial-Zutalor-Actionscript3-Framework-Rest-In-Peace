package com.zutalor.translate 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TranslateProperties extends PropertiesBase implements IProperties
	{	
		public function TranslateProperties() { }
		
		public var language:String;
		public var soundPath:String;
	}
}