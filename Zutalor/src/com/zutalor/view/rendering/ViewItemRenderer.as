package com.zutalor.view.rendering
{
	import com.zutalor.components.base.Component;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.Container;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.translate.Translate;
	import com.zutalor.view.properties.ViewItemProperties;

	public class ViewItemRenderer
	{
		private var onItemRendered:Function;
		private var filterApplier:Function;
		private var positioner:Function;
		private var container:ViewContainer;

		public function ViewItemRenderer(c:ViewContainer, filterApplier:Function, positioner:Function = null)
		{
			this.onItemRendered = onItemRendered;
			this.filterApplier = filterApplier;
			this.positioner = positioner;
			this.container = c;
		}
		
		public function renderItem(vip:ViewItemProperties):ContainerObject
		{
			var viewItem:Component;
			var ViewItemClass:Class;
				
			ViewItemClass = Plugins.getClass(vip.type);
			viewItem = new ViewItemClass(vip.name);
			container.push(viewItem);
			viewItem.name = vip.name;
			viewItem.render(vip);
			filterApplier(vip, viewItem);

			if (positioner != null)
				positioner(vip);

			if (vip.tabIndex)
			{
				viewItem.tabEnabled = true;
				viewItem.tabIndex = vip.tabIndex;
				viewItem.focusRect = true;
			}
			
			if (vip.tapAction)
				viewItem.buttonMode = true;
			
			if (vip.tKey)
				vip.text = Translate.text(vip.tKey);
				
			if (vip.text)
				viewItem.value = vip.text;
				
			if (vip.parent)
				Container(container.getChildByName(vip.parent)).addChild(viewItem);
				
			return viewItem;
		}
	}
}