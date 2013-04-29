package com.zutalor.view.rendering
{
	import com.zutalor.plugin.Plugins;
	import com.zutalor.transition.TransitionTypes;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.view.transition.ViewItemTransition;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewRenderer
	{
		
		private var viewItemFilterApplier:ViewItemFilterApplier;
		private var viewItemRenderer:ViewItemRenderer;
		private var vc:ViewController;
		private var vp:ViewProperties;
		private var itemIndex:int;
		private var onComplete:Function;
		
		public function ViewRenderer(vc:ViewController)
		{
			this.vc = vc;
			vp = vc.vp;
		}
		
		public function render(onComplete:Function):void
		{
			this.onComplete = onComplete;
			viewItemFilterApplier = new ViewItemFilterApplier(vc.filters);
			viewItemRenderer = new ViewItemRenderer(vp.container, viewItemFilterApplier.applyFilters,
																				vc.viewItemPositioner.positionItem);
			renderNextViewItem();
		}
		
		public function dispose():void
		{
			viewItemFilterApplier = null;
			viewItemRenderer = null;
		}
		
		private function renderNextViewItem():void
		{
			var vip:ViewItemProperties;
			var viewItem:*;
			
			if (itemIndex < vc.numViewItems)
			{
				vip = ViewController.presets.getItemPropsByIndex(vc.viewId, itemIndex++);
				if (!vip.styleSheetName)
					vip.styleSheetName = vp.styleSheetName;
				
				viewItem = viewItemRenderer.renderItem(vip);
				if (vip.draggable)
					vc.registerDraggableObject(viewItem);
					
				renderNextViewItem();
			}
			else
				viewPopulateComplete();
		}
		
		private function viewPopulateComplete():void
		{
			var i:int;
			var l:int;
			var nc:int;
			var viewItemTransition:ViewItemTransition;

			var vip:ViewItemProperties;
			nc = vc.container.numChildren;
			vc.viewEventMediator.itemListenerSetup();
			vc.viewEventMediator.addListenersToContainer(vp.container);

			for (i = 0; i < nc; i++)
			{
				vip = ViewController.presets.getItemPropsByIndex(vc.viewId, i);
				if (vip && vip.transitionPreset) {
					viewItemTransition = new ViewItemTransition();
					viewItemTransition.render(vip, vc.container, TransitionTypes.IN);
				}
			}
			
			if (vp.initialMethod)
			{
				if (vp.initialMethodParams)
					Plugins.callMethod(vp.uiControllerInstanceName, vp.initialMethod,vp.initialMethodParams);
				else
					Plugins.callMethod(vp.uiControllerInstanceName, vp.initialMethod);
			}
			onComplete();
		}
	}
}