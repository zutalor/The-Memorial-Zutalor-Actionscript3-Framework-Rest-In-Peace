package com.zutalor.view.rendering 
{
	import adobe.utils.CustomActions;
	import com.zutalor.components.Component;
	import com.zutalor.containers.Container;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.properties.ScrollProperties;
		import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.utils.DisplayUtils;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewItemProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewItemPositioner
	{
		private var _c:Container;
		private var _width:int;
		private var _height:int;
		
		public function ViewItemPositioner(c:Container, width:int, height:int)
		{
			_c = c;
			_width = width;
			_height = height;
		}
		
		public function positionItem(vip:ViewItemProperties):void
		{
			var scrollProperties:ScrollProperties;
			var viewItem:Component;
			var width:int;
			var height:int;
			var x:int;
			var y:int;
			var hPad:int;
			var vPad:int;
			
			viewItem = _c.getChildByName(vip.name) as Component;
			
			width = int(vip.width);
			height = int(vip.height);
			x = int(vip.x);
			y = int(vip.y);
			hPad = int(vip.hPad);
			vPad = int(vip.vPad);
	
							
			if (vip.width)
				if (vip.width == "auto")
					viewItem.width = _c.width - hPad - x;
				else	
					viewItem.width = width;
					
			if (vip.height)
				if (vip.height == "auto")
					viewItem.height = _c.height - vPad - y;
				else
					viewItem.height = height;
						
			if (vip.align)
				DisplayUtils.alignInRect(viewItem, _width, _height, vip.align, vip.hPad, vip.vPad);
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