package com.zutalor.utils 
{
	import com.zutalor.properties.PathProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.propertyManagers.Props;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Path 
	{
		private static var _presets:PropertyManager;
		
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new PropertyManager(PathProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		public static function getPath(p:String):String
		{
			var pp:PathProperties;
			
			pp = _presets.getPropsByName(p);
			if (pp)
				return(pp.path);
			else
				return "";
		}
	}

}