package com.zutalor.components.graphic 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.MapXML;
	/**
	 * 
	 * @author Geoff Pepos
	 */
	public class GraphicItemProperties extends PropertiesBase implements IProperties
	{
		public var type:String;
		public var presetId:String;	
		public var data:String;
		public var scale9Data:String;
		public var rotation:Number;
		public var width:int;
		public var height:int;
		public var scale:Number;
		public var graphicStyle:String;
		public var vPad:int;
		public var hPad:int;
		public var align:String;
		public var blendMode:String;		
		public var easing:String;
		public var brush:String;	
		public var tKey:String;
		public var textAttributes:String;
		public var className:String;
		public var filterPreset:String;
				
		override public function parseXML(xml:XML):Boolean
		{	
			MapXML.attributesToClass(xml , this); // map the properties
			
			if (name)
				name = name.toLowerCase();
			else
				name = TextUtil.getUniqueName();
				
			return true;
		}		
	}
}