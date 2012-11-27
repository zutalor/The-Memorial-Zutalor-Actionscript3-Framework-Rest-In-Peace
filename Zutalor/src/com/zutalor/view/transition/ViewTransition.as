package com.zutalor.view.transition 
{
	import com.zutalor.fx.Transition;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.view.properties.ViewProperties;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewTransition 
	{
		
		public function render(vp:ViewProperties, transitionType:String, onComplete:Function = null):void
		{
			var transition:Transition;
			
			if (vp.transitionPreset)
			{
				transition = ObjectPool.getTransition();
				if (vp.transitionPreset)
					transition.simpleRender(vp.container, vp.transitionPreset,  transitionType, onComplete);
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