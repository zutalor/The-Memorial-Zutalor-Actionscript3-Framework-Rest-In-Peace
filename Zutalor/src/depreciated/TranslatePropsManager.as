package com.zutalor.propertyManagers 
{
	import com.zutalor.utils.Singleton;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TranslatePropsManager extends NestedPropsManager
	{
		private static var _translatePropsManager:TranslatePropsManager;

		public function TranslatePropsManager()
		{
			Singleton.assertSingle(TranslatePropsManager);
		}
		
		public static function gi():TranslatePropsManager
		{
			if (!_translatePropsManager)
				_translatePropsManager = new TranslatePropsManager();

			return _translatePropsManager;
		}
	}
}