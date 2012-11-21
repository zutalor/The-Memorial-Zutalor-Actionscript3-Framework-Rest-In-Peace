package com.zutalor.view.rendering 
{
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.properties.ScrollProperties;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.utils.DisplayUtils;
	import com.zutalor.view.controller.ViewController;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewItemPositioner
	{
		private var _vc:ViewController;
		
		public function ViewItemPositioner(vc:ViewController)
		{
			_vc = vc;
		}
		
		public function positionAllItems():void
		{
			for (var i:int; i < _vc.numViewItems; i++)
				positionItem(_vc.vpm.getItemPropsByIndex(_vc.viewId, i));
		}
		
		public function positionItem(vip:ViewItemProperties):void
		{
			var scrollProperties:ScrollProperties;
			var viewItem:*;
			var c:ViewContainer = _vc.container;
			var width:int;
			var height:int;
			var x:int;
			var y:int;
			var hPad:int;
			var vPad:int;
			
			viewItem = _vc.itemDictionary.getByKey(vip.name);
			
			width = int(vip.width);
			height = int(vip.height);
			x = int(vip.x);
			y = int(vip.y);
			hPad = int(vip.hPad);
			vPad = int(vip.vPad);
	
			if (vip.scrollPreset)
			{
				_vc.vu.updateContainerScrollPosition(vip.scrollPreset);
			}
							
			if (vip.width)
				if (vip.width == "auto")
					viewItem.width = c.width - hPad - x;
				else	
					viewItem.width = width;
					
			if (vip.height)
				if (vip.height == "auto")
					viewItem.height = c.height - vPad - y;
				else
					viewItem.height = height;
						
			if (vip.align)
				DisplayUtils.alignInRect(viewItem, _vc.vp.width, _vc.vp.height, vip.align, vip.hPad, vip.vPad);
			else
			{
				viewItem.x = x + hPad;
				viewItem.y = y + vPad;
			}				
			
			if (vip.rotation)
				viewItem.rotation = vip.rotation;
			
			if (vip.rotationX)
				viewItem.rotationX = vip.rotationX;

			if (vip.rotationY)
				viewItem.rotationY = vip.rotationY;

			if (vip.rotationX)
				viewItem.rotationZ = vip.rotationZ;
			
			if (vip.alpha)
				viewItem.alpha = vip.alpha;
			else
				viewItem.alpha = 1;

			if (vip.hidden)
				viewItem.visible = false;
		}
	}
}