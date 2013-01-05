package com.zutalor.view.rendering 
{
	import adobe.utils.CustomActions;
	import com.zutalor.components.base.Component;
	import com.zutalor.containers.Container;
	import com.zutalor.positioning.Aligner;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewItemProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewItemPositioner
	{
		private var _c:ContainerObject;
		private var _width:int;
		private var _height:int;
		private var aligner:Aligner;
		
		public function ViewItemPositioner(c:ContainerObject, width:int, height:int)
		{
			_c = c;
			_width = width;
			_height = height;
			aligner = new Aligner();
		}
		
		public function positionItem(vip:ViewItemProperties):void
		{
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
					viewItem.width = _width - hPad - x;
				else	
					viewItem.width = width;
					
			if (vip.height)
				if (vip.height == "auto")
					viewItem.height = _width - vPad - y;
				else
					viewItem.height = height;
						
			if (vip.align)
				aligner.alignObject(viewItem, _width, _height, vip.align, vip.hPad, vip.vPad);
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
			
			if (vip.scale)
				viewItem.scaleX = viewItem.scaleY = vip.scale;

			if (vip.hidden)
				viewItem.visible = false;		
		}
	}
}