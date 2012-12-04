package com.zutalor.components.list 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.utils.MapXML;
	import com.zutalor.utils.Path;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ListProperties extends PropertiesBase implements IProperties
	{	
		public var listView:String;
		public var itemButtonId:String;
		public var itemWidth:String;
		public var itemHeight:String;
		public var arrange:String;
		public var padding:Number;
		public var spacing:Number;
		public var url:String;
		public var path:String;
		public var data:String;
		
			
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