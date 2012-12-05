package com.zutalor.media  
{
	import com.zutalor.components.media.playlist.Playlist;
	import com.zutalor.interfaces.IProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.MapXML;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MediaStateProperties
	{	
		public var playlist:Playlist;
		public var layerClipNames:Array;
		public var minClips:int;
		public var maxClips:int;
		public var oddsOfPlaying:int;
		public var clipsCacheSize:int;
		public var allowRepeats:Boolean;
		public var clipFadeOut:Number;
		public var overlap:Number;
	}
}