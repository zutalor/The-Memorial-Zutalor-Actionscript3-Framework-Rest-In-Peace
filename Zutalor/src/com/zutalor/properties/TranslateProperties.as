package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TranslateProperties extends PropertiesBase implements IProperties
	{	
		public var language:String;
		public var soundPath:String;
	}
}