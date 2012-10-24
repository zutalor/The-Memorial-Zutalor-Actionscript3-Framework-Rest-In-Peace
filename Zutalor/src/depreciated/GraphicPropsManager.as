package com.zutalor.propertyManagers 
{
	import com.zutalor.utils.Singleton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class GraphicPropsManager extends NestedPropsManager
	{
		protected static var _graphicPropsManager:GraphicPropsManager;

		public function GraphicPropsManager()
		{
			Singleton.assertSingle(GraphicPropsManager);
		}
		
		public static function gi():GraphicPropsManager
		{
			if (!_graphicPropsManager)
				_graphicPropsManager = new GraphicPropsManager();

			return _graphicPropsManager;
		}
		
	}
}