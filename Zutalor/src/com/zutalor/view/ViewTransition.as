package com.zutalor.view 
{
	import com.zutalor.fx.Transition;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.properties.TransitionProperties;
	import com.zutalor.properties.ViewProperties;
	import com.zutalor.propertyManagers.Props;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewTransition 
	{
		
		public function render(vp:ViewProperties, transitionType:String, onComplete:Function = null):void
		{
			var transition:Transition;
			var tpp:TransitionProperties;
			
			if (vp.transitionPreset)
			{
				transition = ObjectPool.getTransition();
				tpp = Props.pr.transitionPresets.getPropsByName(vp.transitionPreset);	
				if (tpp)
					transition.render(vp.container, tpp.inType, tpp.inEase, tpp.inTime, tpp.inDelay, transitionType, tpp.xValue, tpp.yValue, onComplete);
				else
					if (onComplete != null)
						onComplete();				
			}
			else
				if (onComplete != null)
					onComplete();
		}	
	}	
}