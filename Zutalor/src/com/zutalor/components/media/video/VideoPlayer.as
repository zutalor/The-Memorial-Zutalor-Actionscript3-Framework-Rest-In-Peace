package com.zutalor.components.media.video 
{
	import com.zutalor.properties.MediaProperties;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class VideoPlayer extends MediaPlayer
	{	
		private var _flvController:VideoController;
		
		public function VideoPlayer()
		{
			init();
		}
		
		private function init():void
		{
			_flvController = new VideoController();
			initialize(MediaProperties.PLAYER_VIDE0, _flvController);
		}	
	}		
}