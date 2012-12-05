package com.zutalor.translate 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TranslateItemProperties extends PropertiesBase implements IProperties
	{
		
		public var tText:String;
		public var tMeta:String;
		public var sound:String;
		
		override public function parseXML(xml:XML):Boolean
		{
			MapXML.attributesToClass(xml , this); // map the properties
			
			if (String(xml.tText))
				tText = xml.tText;
				
			if (String(xml.tMeta))
				tMeta = xml.tMeta;
				
			return true;	
		}
	}
}