package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.utils.MapXML;
	import com.zutalor.utils.Path;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TranslateItemProperties extends PropertiesBase implements IProperties
	{
		
		public var tText:String;
		public var tMeta:String;
		public var soundUrl:String;
		public var soundPath:String;
		
		override public function parseXML(xml:XML):Boolean
		{
			MapXML.attributesToClass(xml , this); // map the properties
			
			if (String(xml.tText))
				tText = xml.tText;
				
			if (String(xml.tMeta))
				tMeta = xml.tMeta;
							
			if (String(xml.@soundPath))
			{
				soundUrl = Path.getPath(String(xml.@soundPath)) + xml.@soundUrl;
			}
			return true;	
		}
	}
}