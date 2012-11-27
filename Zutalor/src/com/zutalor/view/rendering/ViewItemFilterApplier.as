package com.zutalor.view.rendering 
{
	import com.zutalor.components.Component;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.fx.Filters;
		import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.view.controller.ViewController;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewItemFilterApplier 
	{
		private var _filters:Array;
			
		public function ViewItemFilterApplier(filters:Array):void
		{
			_filters = filters;
		}
		
		public function applyFilters(vip:ViewItemProperties, viewItem:Component):void
		{
			var mask:Graphic;

			if (vip.filterPreset || vip.maskId)
			{
				if (vip.transitionDelay)
					MasterClock.callOnce(_applyFilters, vip.transitionDelay);
				else
					_applyFilters();						
			}				
			
			function _applyFilters():void
			{
				if (_filters)
				{
					var filters:Filters = new Filters();
					_filters.push(filters);
					filters.add(viewItem, vip.filterPreset);
				}
				
				if (vip.maskId)
				{
					mask = new Graphic();
					mask.vip.presetId = vip.maskId;
					mask.render();
					viewItem.mask = mask;
					viewItem.addChild(mask);
				}		
			}
		}
	}
}