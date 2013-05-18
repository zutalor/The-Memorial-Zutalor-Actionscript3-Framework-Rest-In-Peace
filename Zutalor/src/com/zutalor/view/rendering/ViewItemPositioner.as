package com.zutalor.view.rendering
{
	import com.zutalor.components.base.Component;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.positioning.Aligner;
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
			var w:Number;
			var h:Number;
			var x:Number;
			var y:Number;
			var hPad:Number;
			var vPad:Number;
			
			viewItem = _c.getChildByName(vip.name) as Component;
			
			w = calcWidth(vip.width);
			h = calcHeight(vip.height);
			x = calcWidth(vip.x);
			y = calcHeight(vip.y);
			hPad = calcWidth(vip.hPad);
			vPad = calcHeight(vip.vPad);
			
			if (w)
				viewItem.width = w;
					
			if (h)
				viewItem.height = h;
						
			if (vip.align)
			{
				aligner.alignObject(viewItem, _containerWidth, _containerHeight, vip.align, hPad, vPad);
			}
			else
			{
				viewItem.x = x + hPad;
				viewItem.y = y + vPad;
			}
			
			if (vip.z)
				viewItem.z = vip.z;
			
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