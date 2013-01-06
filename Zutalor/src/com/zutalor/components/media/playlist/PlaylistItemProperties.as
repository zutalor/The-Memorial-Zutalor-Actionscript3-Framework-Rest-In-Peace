package com.zutalor.components.media.playlist  
{
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	public class PlaylistItemProperties extends PropertiesBase implements IProperties
	{	
		public var type:String;
		public var x:int;
		public var y:int;
		public var z:int;
		public var width:int;
		public var height:int;
		public var alpha:Number = 1;
		public var url:String;
		public var filterPreset:String;
		public var start:int;
		public var end:int;
		public var playNext:String;
		public var volume:Number = 1;
		public var oddsOfPlaying:int = 1; //for the ai clip player
		public var context:String;
		public var startDelay:Number;
		public var audioFadeIn:Number;
		public var videoFadeIn:Number;
		public var fadeOut:Number;
		public var loop:int;
		public var loopDelay:Number
		public var hotkey:String;
		public var hotkeyTriggerMode:String;
	}
}