﻿package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.utils.MapXML;
	import com.zutalor.utils.Path;
	import flash.text.StyleSheet;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class CssProperties extends PropertiesBase implements IProperties
	{		
		public var url:String;
		public var path:String;
		public var styleSheet:StyleSheet;
		
		override public function parseXML(xml:XML):Boolean
		{
			MapXML.attributeToClass(xml , this); // map the properties

			if (String(xml.@path))
				url = Path.getPath(String(xml.@path)) + xml.@url;
			else
				url = xml.@url;

			return true;	
		}		
	}
}