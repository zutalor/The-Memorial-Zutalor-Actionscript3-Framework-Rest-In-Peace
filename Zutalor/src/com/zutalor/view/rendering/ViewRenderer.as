package com.zutalor.view.rendering
{
	import com.zutalor.components.Component;
	import com.zutalor.containers.Container;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.translate.Translate;
	import com.zutalor.view.properties.ViewItemProperties;

	public class ViewRenderer
	{
		private var _onItemRenderCallback:Function;	
		private var _applyFilters:Function;
		private var _positionItem:Function;
		private var _container:Container;

		public function ViewRenderer(container:Container, onItemRenderCallback:Function, applyFilters:Function, positionItem:Function = null) 
		{	
			_onItemRenderCallback = onItemRenderCallback;
			_applyFilters = applyFilters;
			_positionItem = positionItem;
			_container = container;
		}
		
		public function renderItem(vip:ViewItemProperties):void
		{
			var viewItem:Component;
			var ViewItemClass:Class;
			var vip:ViewItemProperties;
			
			if (vip.tKey)
				vip.text = Translate.text(vip.tKey);
			else
				vip.text = vip.text;
		
			ViewItemClass = Plugins.getClass(vip.type);
			viewItem = new ViewItemClass(vip.name);
			viewItem.render(vip);
	
			if (!vip.excludeFromDisplayList) 
				_container.push(viewItem);

			viewItem.name = vip.name;
			
			_applyFilters(vip, viewItem);
			
			if (_positionItem != null)
				_positionItem(vip);
			
			if (vip.tabIndex)
			{
				viewItem.tabEnabled = true;
				viewItem.tabIndex = vip.tabIndex;
				viewItem.focusRect = true;
			}	
			_onItemRenderCallback();
		}
	}
}