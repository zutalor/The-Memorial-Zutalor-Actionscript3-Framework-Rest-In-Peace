package com.zutalor.properties 
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.MapXML;
	import com.zutalor.utils.Path;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class PlaylistProperties extends PropertiesBase implements IProperties
	{
		public var path:String;
		public var playerClassName:String;
		public var defaultImageLength:Number;
		public var bufferTime:Number;
		public var autoPlay:Boolean;
		public var scaleToFit:Boolean;
		public var startDelay:Number;
		public var loop:int;
		public var loopDelay:Number;
		public var startIndex:int;
		public var endIndex:int;
		public var totalLength:Number;
		public var videoFadeIn:Number;
		public var audioFadeIn:Number;
		public var overlap:Number;
		public var clipFadeOut:Number;
		public var endFadeOut:Number;
		public var allowRepeats:Boolean;
		public var toolsContainer:String;
		public var toolsView:String;
		public var respondToControlKeys:Boolean;
		public var toolsAttached:Boolean;
		
		public var ai:Boolean; //the below only become used if this is true;
		public var minClips:int;
		public var maxClips:int;
		public var oddsOfPlaying:int;
		public var startVariance:Number;		
		public var endVariance:Number;		
				
		override public function parseXML(xml:XML):Boolean
		{
			MapXML.attributeToClass(xml , this); // map the properties
			name = name.toLowerCase();
			
			if (String(xml.@path))
				path = Path.getPath(String(xml.@path));
				
			return true;
		}
	}
}