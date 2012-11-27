package com.zutalor.components.list 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ListProperties extends PropertiesBase implements IProperties
	{	
		public var closedStatePresetId:String;
		public var closedStateType:String;
		public var listView:String;
		public var itemView:String;
		public var width:String;
		public var height:String;
		public var itemWidth:String;
		public var itemHeight:String;
		public var align:String;
		public var hPad:String;
		public var vPad:Number;
		public var spacing:Number;
		public var tKey:String;
	}
}