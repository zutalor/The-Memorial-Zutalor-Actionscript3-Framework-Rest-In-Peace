package com.zutalor.media 
{		
	import com.zutalor.properties.MediaProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AudioPlayer extends MediaPlayer
	{
		private var _audioController:AudioController;
		
		public function AudioPlayer()
		{
			init();
		}
		
		private function init():void
		{
			_audioController = new AudioController();
			initialize(MediaProperties.PLAYER_AUDIO, _audioController)
		}		
	}
}