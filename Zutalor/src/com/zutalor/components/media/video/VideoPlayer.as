package com.zutalor.components.media.video 
{
	import com.zutalor.components.media.base.MediaPlayer;
	import com.zutalor.components.media.base.MediaProperties;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class VideoPlayer extends MediaPlayer
	{	
		private var _flvController:VideoController;
		
		public function VideoPlayer(name:String)
		{
			super(name);
			init();
		}
		
		private function init():void
		{
			_flvController = new VideoController();
			initialize(MediaProperties.PLAYER_VIDE0, _flvController);
		}	
	}		
}