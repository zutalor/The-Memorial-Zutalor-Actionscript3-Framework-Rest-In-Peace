package com.zutalor.filters 
{
	import com.zutalor.filters.base.FuzzyFilter;
	import com.zutalor.filters.base.FuzzyFilterProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import flash.filters.GlowFilter;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Glow extends FuzzyFilter 
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
			return GlowFilter;
		}
	}
}