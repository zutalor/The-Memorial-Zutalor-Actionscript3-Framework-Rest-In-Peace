package com.zutalor.view.rendering
{
	import com.zutalor.components.base.Component;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.Container;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.translate.Translate;
	import com.zutalor.view.properties.ViewItemProperties;

	public class ViewItemRenderer
	{
		private var onItemRendered:Function;	
		private var filterApplier:Function;
		private var positioner:Function;
		private var container:Container;

		public function ViewItemRenderer(c:Container, filterApplier:Function, positioner:Function = null) 
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
			var vip:ViewItemProperties;
			
			if (vip.tKey)
				vip.text = Translate.text(vip.tKey);
				
			ViewItemClass = Plugins.getClass(vip.type);
			viewItem = new ViewItemClass(vip.name);
							
			if (!viewItem.isInvisible) 
				container.push(viewItem);
				
			viewItem.name = vip.name;
			if (vip.name == "speed")
				trace();
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
			
			return viewItem;
		}
	}
}