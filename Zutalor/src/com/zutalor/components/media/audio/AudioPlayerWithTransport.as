package com.zutalor.components.media.audio 
{		
	import com.zutalor.constants.MediaPlayerTypes;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AudioPlayerWithTransport extends MediaPlayerWithTransport
	{
		private var _audioController:AudioController;
		
		public function AudioPlayerWithTransport()
		{
			init();
		}
		
		private function init():void
		{
			_audioController = new AudioController();
			initialize(MediaPlayerTypes.audio, _audioController)
		}		
	}
}