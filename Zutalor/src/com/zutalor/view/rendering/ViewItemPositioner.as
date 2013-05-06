package com.zutalor.view.rendering
{
	import adobe.utils.CustomActions;
	import com.zutalor.components.base.Component;
	import com.zutalor.containers.Container;
	import com.zutalor.positioning.Aligner;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
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
		private var _containerWidth:Number;
		private var _containerHeight:Number;
		private var aligner:Aligner;
		
		public function ViewItemPositioner(c:ContainerObject, width:Number, height:Number)
		{
			_c = c;
			_containerWidth = width;
			_containerHeight = height;
			aligner = new Aligner();
		}
		
		public function positionItem(vip:ViewItemProperties):void
		{
			var viewItem:Component;
			
			viewItem = _c.getChildByName(vip.name) as Component;
			
			vip.width = calcWidth(vip.width);
			vip.height = calcHeight(vip.height);
			vip.x = calcWidth(vip.x);
			vip.y = calcHeight(vip.y);
			vip.hPad = calcWidth(vip.hPad);
			vip.vPad = calcHeight(vip.vPad);
			
			if (vip.width)
				viewItem.width = vip.width;
					
			if (vip.height)
				viewItem.height = vip.height;
						
			if (vip.align)
				aligner.alignObject(viewItem, _containerWidth, _containerHeight, vip.align, vip.hPad, vip.vPad);
			else
			{
				viewItem.x = vip.x + vip.hPad;
				viewItem.y = vip.y + vip.vPad;
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
				
		private function calcWidth(w:Number):Number
		{
			if (isNaN(w))
				return 0;
			else if (w <= 1 && w > 0)
				return _containerWidth * w;
			else
				return w;
		}
		
		private function calcHeight(h:Number):Number
		{
			if (isNaN(h))
				return 0;
			else if (h <= 1 && h > 0)
				return _containerHeight * h;
			else
				return h;
		}
	}
}