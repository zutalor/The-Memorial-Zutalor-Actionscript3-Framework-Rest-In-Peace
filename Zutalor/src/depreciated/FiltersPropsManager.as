package com.zutalor.propertyManagers 
{
	import com.zutalor.utils.Singleton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class FiltersPropsManager extends NestedPropsManager
	{
		protected static var _filtersPropsManager:FiltersPropsManager;

		public function FiltersPropsManager()
		{
			Singleton.assertSingle(FiltersPropsManager);
		}
		
		public static function gi():FiltersPropsManager
		{
			if (!_filtersPropsManager)
				_filtersPropsManager = new FiltersPropsManager();

			return _filtersPropsManager;
		}
		
	}
}