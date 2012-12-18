package com.zutalor.components.list 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.path.Path;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ListProperties extends PropertiesBase implements IProperties
	{	
		public var listView:String;
		public var itemPresetId:String;
		public var scrollAreaWidth:Number;
		public var scrollAreaHeight:Number;
		public var orientation:String;
		public var align:String;
		public var itemWidth:Number;
		public var itemHeight:Number;
		public var quantizeHPosition:Boolean;
		public var quantizeVPosition:Boolean;
		public var hPad:Number;
		public var vPad:Number;
		public var url:String;
		public var path:String;
		public var data:String;
		public var itemRenderer:String;
		
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