package com.zutalor.components.graphic  
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.utils.MapXML;
	import flash.display.LineScaleMode;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class GraphicStyleProperties extends PropertiesBase implements IProperties
	{		
		public var alpha:Number;
		public var lineColor:uint;
		public var thickness:int;
		public var lineAlpha:Number;
		public var fillColor:uint;
		public var fillLibraryName:String;
		public var fillClassName:String;
		public var fillRepeat:Boolean;
		public var fillAlpha:Number;
		public var caps:String;
		public var joints:String;	
		public var scaleMode:String;
		
		public var fillType:String; //gradient
		public var colors:String;
		public var alphas:String;
		public var ratios:String;
		public var rotation:int;
		public var spreadMethod:String;
		
		public var colorsArray:Array;
		public var alphasArray:Array;
		public var ratiosArray:Array;
	
		
		override public function parseXML(xml:XML):Boolean
		{	
			MapXML.attributesToClass(xml , this); // map the properties
			name = name.toLowerCase();
			
			if (colors)
				colorsArray = colors.split(",");
			
			if (alphas)
				alphasArray = alphas.split(",");
			
			if (ratios)
				ratiosArray = ratios.split(",");
			
			if (!scaleMode)
				scaleMode = LineScaleMode.NORMAL;				
			
			return true;
		}
	}
}