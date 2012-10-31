package com.zutalor.view  
{
	import com.zutalor.fx.Transition;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.properties.ViewProperties;
	import com.zutalor.propertyManagers.Presets
	import com.zutalor.properties.TransitionProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.gDictionary;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewItemTransition
	{				
		public function render(vip:ViewItemProperties, viq:gDictionary, inOut:String):void
		{
			var transition:Transition;
			var t:Function;
			var tpp:TransitionProperties;
			var transitionDelay:Number;
			var viewItem:*;
			
			if (!vip.hidden)
			{
				viewItem = viq.getByKey(vip.name);
				if (vip.transitionPreset)
				{		
					tpp = Props.pr.transitionPresets.getPropsByName(vip.transitionPreset);
					if (tpp)
					{
						transition = ObjectPool.getTransition();
						
						if (!vip.transitionDelay)
							transitionDelay = tpp.inDelay;
						else
							transitionDelay = vip.transitionDelay;
														
						
						viewItem.alpha = vip.alpha;
						transition.render(viewItem, tpp.inType, tpp.inEase, tpp.inTime, transitionDelay, inOut, tpp.xValue, tpp.yValue);
					}
				}
			}
		}			
	}
}