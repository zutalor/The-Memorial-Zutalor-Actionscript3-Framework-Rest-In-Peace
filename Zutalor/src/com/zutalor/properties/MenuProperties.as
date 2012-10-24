package com.zutalor.properties
{
	import com.zutalor.interfaces.IProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 * 
	 */
	
	public class MenuProperties extends PropertiesBase implements IProperties
	{
		public static const LINK:String = "link";
		public static const VIEW:String = "view";
		public static const SEQUENCE:String = "sequence";

		public var type:String;
		public var sequenceName:String;
		public var viewId:String;
		public var transitionPreset:String;
		public var scrollPreset:String;
		public var mediaPreset:String;
		public var hotkey:String;
		public var url:String;
	}
}