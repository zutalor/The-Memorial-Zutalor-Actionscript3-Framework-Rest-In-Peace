package com.zutalor.properties  
{
	import com.zutalor.interfaces.IProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MediaProperties extends PropertiesBase implements IProperties
	{
		public static const PLAYER_VIDE0:String = "video";
		public static const PLAYER_IMAGE:String = "image";
		public static const PLAYER_AUDIO:String = "audio";
		public static const PLAYER_YOUTUBE:String = "youTube";
		
		public var width:int;
		public var height:int;
		public var volume:Number = 1;
		public var autoPlay:Boolean;
		public var loopCount:int; // -1 for infinite loop (well up to int.MAX_VALUE)
		public var startDelay:Number;
		public var loopDelay:Number;
		public var scaleToFit:Boolean = true;
		public var mediaFadeIn:Number;
		public var audioFadeIn:Number;
		public var slideDelay:Number;
		public var fps:Number;
		public var urlExtension:String;
		public var crossFade:Number;
		public var backgroundColor:uint;
		public var fadeOut:Number;
		public var hideOnPlayComplete:Boolean;
		public var controlsViewId:String;
		public var controlsContainerName:String;
	}
}