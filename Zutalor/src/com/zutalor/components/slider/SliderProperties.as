package com.zutalor.components.slider 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SliderProperties extends PropertiesBase implements IProperties
	{
		public var thumbButtonId:String;
		public var trackButtonId:String;
		public var revealId:String;
		public var vertical:Boolean;
		public var numSteps:int;
		public var tweenTime:Number;
		public var onlyShowTrackOnMouseDown:Boolean;
	}
}