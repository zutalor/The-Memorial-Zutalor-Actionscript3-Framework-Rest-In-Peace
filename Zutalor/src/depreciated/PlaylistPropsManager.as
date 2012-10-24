package com.zutalor.propertyManagers 
{
	import com.zutalor.utils.Singleton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class PlaylistPropsManager extends NestedPropsManager
	{
		protected static var _playlistPropsManager:PlaylistPropsManager;

		public function PlaylistPropsManager()
		{
			Singleton.assertSingle(PlaylistPropsManager);
		}
		
		public static function gi():PlaylistPropsManager
		{
			if (!_playlistPropsManager)
				_playlistPropsManager = new PlaylistPropsManager();

			return _playlistPropsManager;
		}
		
	}
}