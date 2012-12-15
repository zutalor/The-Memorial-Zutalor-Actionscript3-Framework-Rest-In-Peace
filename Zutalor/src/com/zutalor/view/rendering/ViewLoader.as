package com.zutalor.view.rendering
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.fx.Filters;
	import com.zutalor.fx.TransitionTypes;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.ShowError;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.view.transition.ViewTransition;
	import flash.events.EventDispatcher;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewLoader extends EventDispatcher
	{
		
		private var vp:ViewProperties;
		private var c:ViewContainer; 
		private var _onComplete:Function;
		private var _parent:ContainerObject;
		
		public function ViewLoader(parent:ContainerObject = null)
		{
			_parent = parent;
		}
		
		public function get container():ViewContainer
		{
			return vp.container;
		}
				
		public function load(viewId:String, appState:String = null, onComplete:Function=null):void
		{			
			_onComplete = onComplete;

			vp = ViewController.presets.getPropsById(viewId);		
			
			if (c)
				vp.container = c;
			else if (!vp.container)
				ObjectPool.getContainer(vp);
		
			c = vp.container;
			c.x = vp.x;
			c.y = vp.y;
			c.rotation = vp.rotation;
			
			if (vp.blendMode)
				c.blendMode = vp.blendMode;
			
			if (vp.scale)
			{
				c.scaleX = c.scaleY = vp.scale;
				c.scaleY = c.scaleY = vp.scale;
			}
								
			if (vp.width)
				c.width = vp.width;
				
			if (vp.height)
				c.height = vp.height;

			if (vp.z)
				c.z = vp.z
			
			if (vp.rotX)
				c.rotationX = vp.rotX;

			if (vp.rotY)
				c.rotationY = vp.rotY;
						
			if (vp.rotZ)
				c.rotationZ = vp.rotZ;
			
			c.vx = vp.vx;
			c.vy = vp.vy;
			
			if (vp.vz)
				c.vz = vp.vz;
			
			vp.container.posOffsetX = vp.hPad;
			vp.container.posOffsetY = vp.vPad;
			
			if (vp.alpha)
				vp.container.alpha = vp.alpha;
			
			if (vp.filterPreset)
			{
				var filters:Filters = new Filters();
				filters.add(vp.container, vp.filterPreset);
			}
			
			if (!viewId)
				ShowError.fail(ViewLoader,"View Id cannot be null: " + viewId);
					
			if (!c.viewController)
				c.viewController = new ViewController();
						
			c.viewController.load(viewId, appState, viewLoadComplete);					
		}	
		
		private function viewLoadComplete():void
		{
			var vt:ViewTransition;	
			
			if (!vp.width  || !vp.height)
			{
				vp.width = vp.container.width;
				vp.height = vp.container.height;
			}	
			if (_parent)
				_parent.addChild(vp.container);
				
		
			if (!vp.transitionPreset)
				vp.transitionPreset = "fade";
			
			vt = new ViewTransition();
			vt.render(vp, TransitionTypes.IN);
			if (_onComplete != null)
				_onComplete();
		}
	}
}