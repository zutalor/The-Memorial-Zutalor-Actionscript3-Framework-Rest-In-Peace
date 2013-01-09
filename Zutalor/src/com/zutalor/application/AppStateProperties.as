package com.zutalor.application
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 * 
	 */
	
	public class AppStateProperties extends PropertiesBase implements IProperties
	{
		public function AppStateProperties() { }
		
		public static const VIEW:String = "view";
		public static const SEQUENCE:String = "sequence";

		public var type:String;
		public var sequenceName:String;
		public var viewId:String;
		public var transitionPreset:String;
		public var scrollPreset:String;
		public var mediaPreset:String;
		public var hotkey:String;
	}
}