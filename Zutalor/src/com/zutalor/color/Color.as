package com.zutalor.color 
{
	import com.zutalor.propertyManagers.NestedPropsManager;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Color 
	{
		
		public function Color() 
		{
			
		}
			
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new PropertyManager(ButtonProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
	}
}