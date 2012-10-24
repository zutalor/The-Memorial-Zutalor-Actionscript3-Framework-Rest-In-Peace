package com.zutalor.propertyManagers 
{
	import com.zutalor.utils.Singleton;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class StyleSheetPropsManager extends NestedPropsManager
	{
		private static var _stylesheetPropsManager:StyleSheetPropsManager;

		public function StyleSheetPropsManager()
		{
			Singleton.assertSingle(StyleSheetPropsManager);
		}
		
		public static function gi():StyleSheetPropsManager
		{
			if (!_stylesheetPropsManager)
				_stylesheetPropsManager = new StyleSheetPropsManager();

			return _stylesheetPropsManager;
		}
	}
}