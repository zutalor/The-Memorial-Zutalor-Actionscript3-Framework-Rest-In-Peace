package com.zutalor.view.transition  
{
	import com.zutalor.containers.Container;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.transition.Transition;
	import com.zutalor.view.properties.ViewItemProperties;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewItemTransition
	{				
		public function render(vip:ViewItemProperties, vc:Container, inOut:String):void
		{
			var transition:Transition;
			var t:Function;
			var transitionDelay:Number;
			var viewItem:*;
			
			if (!vip.hidden)
			{
				viewItem = vc.getChildByName(vip.name);
				if (vip.transitionPreset)
				{
					transition = ObjectPool.getTransition();
					
					if (vip.transitionDelay)
						transition.delay = vip.transitionDelay;
						
					viewItem.alpha = vip.alpha;
					transition.simpleRender(viewItem, vip.transitionPreset, inOut);
				}
			}
		}			
	}
}