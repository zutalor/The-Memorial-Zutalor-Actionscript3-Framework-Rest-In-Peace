package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SliderProperties extends PropertiesBase implements IProperties
	{
		public var thumbButtonId:String;
		public var trackButtonId:String;
		public var revealGraphicId:String;
		public var vertical:Boolean;
		public var numSteps:int;
		public var tweenTime:Number;
		public var onlyShowTrackOnMouseDown:Boolean;
	}
}