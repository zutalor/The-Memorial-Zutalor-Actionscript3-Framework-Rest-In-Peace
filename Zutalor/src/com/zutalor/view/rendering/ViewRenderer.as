package com.zutalor.view.rendering
{
import com.zutalor.containers.ViewContainer;
import com.zutalor.plugin.Plugins;
import com.zutalor.properties.ApplicationProperties;
import com.zutalor.properties.ViewItemProperties;
import com.zutalor.properties.ViewProperties;
import com.zutalor.propertyManagers.Presets;
import com.zutalor.propertyManagers.Props;
import com.zutalor.text.Translate;
import com.zutalor.view.controller.ViewController;
import com.zutalor.view.utils.ViewUtils;

	public class ViewRenderer
	{
		private var _pr:Presets;
		private var _ap:ApplicationProperties;
		private var _tabIndex:int;
		private var _onItemRenderCallback:Function;
		
		public var vc:ViewController;
		public var vp:ViewProperties;
		public var vu:ViewUtils;
		
		private var _viewItemFilterApplier:ViewItemFilterApplier;
								
		public function ViewRenderer(viewController:ViewController, onItemRenderCallback:Function) 
		{	
			_onItemRenderCallback = onItemRenderCallback;
			vc = viewController;
			_pr = Props.pr;
			_ap = ApplicationProperties.gi();
			_viewItemFilterApplier = new ViewItemFilterApplier(vc);
		}
		
		public function renderItem(itemIndex:int):void
		{
			var c:ViewContainer;
			var viewItem:*;
			var ViewItemClass:Class;
			var vip:ViewItemProperties;

			vip = Props.views.getItemPropsByIndex(vc.viewId, itemIndex);
			
			c = vc.vp.container;			
			c.visible = true;	
			vc.containergDictionary.insert(c.name, c);
		
			if (vip.tKey)
				vip.text = Translate.text(vip.tKey);
			else
				vip.text = vip.text;
				
			if (!vip.styleSheetName)
				vip.styleSheetName = vp.styleSheetName;
				
			vc.disabledList[itemIndex] = true;
			ViewItemClass = Plugins.getClass(vip.type);
			viewItem = new ViewItemClass();
			viewItem.render(vip);
	
			if (!vip.excludeFromDisplayList) 
				c.push(viewItem);

			viewItem.name = vip.name;
			vc.itemDictionary.insert(vip.name, viewItem);
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