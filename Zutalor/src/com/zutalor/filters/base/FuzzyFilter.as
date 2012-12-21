package com.zutalor.filters.base 
{
	import adobe.utils.CustomActions;
	import com.zutalor.filters.base.FuzzyFilterProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import flash.net.getClassByAlias;
	/**
	 * ...
	 * @author Geoff
	 */
	public class FuzzyFilter
	{
		protected static var _presets:PropertyManager;
		
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new PropertyManager(FuzzyFilterProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		protected function getClass():Class
		{
			return null;
		}
				
		public function get(preset:String):*
		{
			var p:FuzzyFilterProperties
			var klass:Class;
			var f:*;
			
			klass = getClass();
			
			f = new klass();
			p = _presets.getPropsByName(preset);
			if (p)
			{
				f.distance - p.distance;
				f.angle = p.angle;
				f.color = p.color;
				f.alpha = p.alpha;
				f.blurX = p.blurX;
				f.blurY = p.blurY;
				f.strength = 1;
				f.quality = p.quality;;
			}
			return f;
		}
	}
}