﻿package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class GraphicItemProperties extends PropertiesBase implements IProperties
	{
		public var type:String;
		public var data:String;
		public var scale9Data:String;
		public var rotation:Number;
		public var width:int;
		public var height:int;
		public var scale:Number;
		public var graphicStyle:String;
		public var align:String;
		public var vPad:int;
		public var hPad:int;				
		public var endcap:String;
		public var paintTime:Number;
		public var blendMode:String;		
		public var easing:String;
		public var brush:String;	
		public var tKey:String;
		public var tText:String;
		public var textAttribute:String;
		public var graphicId:String;
		public var className:String;
		public var spriteSheet:String;
		public var spriteSheetItem:String;
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