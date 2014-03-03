package com.zutalor.components.media.video
{
	import com.zutalor.properties.PropertiesBase;
	/**
	 * ...
	 * @author Geoff
	 */
		
	public class VideoSettings extends PropertiesBase
	{
		public var url:String;
		public var extension:String;
		public var segments:int;
		public var repeat:int;
		public var randomize:Boolean;
		public var urls:Array;
		
		public function VideoSettings() 
		{
			urls = [];
		}
	}
}