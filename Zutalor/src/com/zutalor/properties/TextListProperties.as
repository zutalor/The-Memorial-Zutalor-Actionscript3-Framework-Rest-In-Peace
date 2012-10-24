package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TextListProperties extends PropertiesBase implements IProperties
	{
		public var item:String;
				
		override public function parseXML(xml:XML):Boolean
		{
			MapXML.attributeToClass(xml , this); // map the properties
			
			if (name)
				name = name.toLowerCase();
			else	
				name = TextUtil.getUniqueName();
				
			return true;
		}
	}
}