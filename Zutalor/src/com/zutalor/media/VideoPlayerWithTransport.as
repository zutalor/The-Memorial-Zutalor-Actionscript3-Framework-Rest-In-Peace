package com.zutalor.media 
{
	import com.zutalor.constants.MediaPlayerTypes;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class VideoPlayerWithTransport extends MediaPlayerWithTransport
	{	
		private var _flvController:VideoController;
		
		public function VideoPlayerWithTransport()
		{
			init();
		}
		
		private function init():void
		{
			_flvController = new VideoController();
			initialize(MediaPlayerTypes.video, _flvController);
		}	
	}		
}