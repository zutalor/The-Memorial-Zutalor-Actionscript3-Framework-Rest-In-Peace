package com.zutalor.media 
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.constants.MediaPlayerTypes;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class YouTubePlayer extends MediaPlayer implements IDisposable
	{	
		private var _youTubeController:YouTubeController;
		
		public function YouTubePlayer()
		{
			_playerType = MediaPlayerTypes.youTube;
			_youTubeController = new YouTubeController();
			super(_youTubeController);
		}
			
		override public function dispose():void
		{
			super.dispose();
			_youTubeController.dispose();
			_youTubeController = null;
		}		
	}		
}