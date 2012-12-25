package com.zutalor.filters
{
	import com.zutalor.filters.base.FuzzyFilter;
	import com.zutalor.filters.base.FuzzyFilterProperties;
	import com.zutalor.properties.PropertyManager;
	import flash.filters.DropShadowFilter;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class Shadow extends FuzzyFilter
	{
		protected static var _presets:PropertyManager;
		
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new PropertyManager(FuzzyFilterProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		override protected function getClass():Class
		{
			return DropShadowFilter;
		}
	}
}