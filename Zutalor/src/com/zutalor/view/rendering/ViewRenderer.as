package com.zutalor.view.rendering
{
import com.zutalor.components.Component;
import com.zutalor.containers.ViewContainer;
import com.zutalor.plugin.Plugins;
import com.zutalor.properties.ViewItemProperties;
import com.zutalor.text.Translate;
import com.zutalor.view.controller.ViewController;

	public class ViewRenderer
	{
		private var _onItemRenderCallback:Function;
		private var _viewItemFilterApplier:ViewItemFilterApplier;		
		public var vc:ViewController;

		public function ViewRenderer(viewController:ViewController, onItemRenderCallback:Function) 
		{	
			_onItemRenderCallback = onItemRenderCallback;
			vc = viewController;
			_viewItemFilterApplier = new ViewItemFilterApplier(vc);
		}
		
		public function renderItem(itemIndex:int):void
		{
			var c:ViewContainer;
			var viewItem:Component;
			var ViewItemClass:Class;
			var vip:ViewItemProperties;

			vip = ViewController.views.getItemPropsByIndex(vc.viewId, itemIndex);
			
			c = vc.vp.container;			
			c.visible = true;	
			vc.containergDictionary.insert(c.name, c);
		
			if (vip.tKey)
				vip.text = Translate.text(vip.tKey);
			else
				vip.text = vip.text;
				
			if (!vip.styleSheetName)
				vip.styleSheetName = vc.vp.styleSheetName;
				
			ViewItemClass = Plugins.getClass(vip.type);
			viewItem = new ViewItemClass();
			viewItem.render(vip);
	
			if (!vip.excludeFromDisplayList) 
				c.push(viewItem);

			viewItem.name = vip.name;
			_viewItemFilterApplier.applyFilters(vip, viewItem);
			vc.viewItemPositioner.positionItem(vip);
			
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