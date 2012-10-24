package com.zutalor.propertyManagers 
{
	import com.zutalor.utils.Singleton;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SpriteSheetPropsManager extends NestedPropsManager
	{
		protected static var _spriteSheetPropsManager:SpriteSheetPropsManager;

		public function SpriteSheetPropsManager()
		{
			Singleton.assertSingle(SpriteSheetPropsManager);
		}
		
		public static function gi():SpriteSheetPropsManager
		{
			if (!_spriteSheetPropsManager)
				_spriteSheetPropsManager = new SpriteSheetPropsManager();

			return _spriteSheetPropsManager;
		}
		
	}
}