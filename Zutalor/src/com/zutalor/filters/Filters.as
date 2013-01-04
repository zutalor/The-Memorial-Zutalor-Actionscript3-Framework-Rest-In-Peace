package com.zutalor.filters 
{
	import com.greensock.plugins.FilterPlugin;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.NestedPropsManager;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.DropShadowFilter;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Filters implements IDisposable
	{
		public static const SHADOW_PRESET:String = "shadowPreset";
		public static const GLOW_PRESET:String = "glowPreset";
		public static const RIPPLE_PRESET:String = "ripplePreset";
		public static const REFLECTION_PRESET:String = "reflectionPreset";
		public static const LIQUIFY_PRESET:String = "liquifyPreset";
		
		
		private var _d:DisplayObject;
		
		private static var _filterPresets:NestedPropsManager;
				
		public static function registerPresets(options:Object):void
		{
			if (!_filterPresets)
				_filterPresets = new NestedPropsManager();
			
			_filterPresets.parseXML(FiltersProperties, FiltersItemProperties, options.xml[options.nodeId], options.childNodeId, 
																				options.xml[options.childNodeId]);
		}
		
		public function dispose():void
		{
			
		}
		
		public function add(d:DisplayObjectContainer, preset:String):void
		{	
			var numFilters:int;
			var fp:FiltersProperties;
			var fip:FiltersItemProperties;
			var filter:*;
			
			var filters:Array = [];

			_d = d;
			fp = _filterPresets.getPropsById(preset);
			
			numFilters = _filterPresets.getNumItems(preset);
			
			for (var i:int = 0; i < numFilters; i++)
			{
				fip = _filterPresets.getItemPropsByIndex(preset, i);
				filter = Plugins.getNewInstance(fip.type);
				filters[i] =  filter.get(fip.preset);
				_d.filters = filters;
			}
		}
	}
}