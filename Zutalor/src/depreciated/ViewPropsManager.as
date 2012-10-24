package com.zutalor.propertyManagers 
{
	import com.zutalor.utils.Singleton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewPropsManager extends NestedPropsManager
	{
		protected static var _viewPropsManager:ViewPropsManager;

		public function ViewPropsManager()
		{
			Singleton.assertSingle(ViewPropsManager);
		}
		
		public static function gi():ViewPropsManager
		{
			if (!_viewPropsManager)
				_viewPropsManager = new ViewPropsManager();

			return _viewPropsManager;
		}
		
	}
}