package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.utils.Path;
	import com.zutalor.utils.MapXML;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class BitmapProperties extends PropertiesBase implements IProperties
	{		
		public var url:String;
		public var path:String;
		public var bitmap:Bitmap;
		
		override public function parseXML(xml:XML):Boolean
		{
			MapXML.attributesToClass(xml , this); // map the properties

			if (String(xml.@path))
					url = Path.getPath(String(xml.@path)) + xml.@url;
				else
					url = xml.@url;
			
			return true;		
		}
	}
}