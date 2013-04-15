package com.zutalor.translate
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TranslationProperties extends PropertiesBase implements IProperties
	{
		public var tText:String;
		public var tMeta:String;
		public var sound:String;
		public var alreadyMerged:Boolean;
		
		public function TranslationProperties() { }
		
		override public function parseXML(xml:XML):Boolean
		{
			MapXML.attributesToClass(xml , this);
			
			if (String(xml.tText))
				tText = xml.tText;
				
			if (String(xml.tMeta))
				tMeta = xml.tMeta;
				
			return true;
		}
	}
}