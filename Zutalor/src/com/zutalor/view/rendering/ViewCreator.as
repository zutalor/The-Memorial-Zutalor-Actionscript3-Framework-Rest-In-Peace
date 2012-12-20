﻿package com.zutalor.view.rendering
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.fx.Filters;
	import com.zutalor.fx.TransitionTypes;
	import com.zutalor.objectPool.ObjectPool;
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
	public class ViewCreator extends EventDispatcher
	{
		
		private var vp:ViewProperties;
		private var c:ViewContainer;
		private var _onComplete:Function;
		private var _parent:ContainerObject;
		
		public function ViewCreator(parent:ContainerObject = null)
		{
			_parent = parent;
		}
		
		public function get container():ViewContainer
		{
			return vp.container;
		}
				
		public function create(viewId:String, appState:String = null, onComplete:Function=null):void
		{			
			if (!viewId)
				ShowError.fail(ViewCreator,"View Id cannot be null: " + viewId);

			_onComplete = onComplete;
			vp = ViewController.presets.getPropsById(viewId);		
			
			vp.container = c = ObjectPool.getViewContainer(vp);
			
			if (!c.viewController)
				c.viewController = new ViewController();
			
			if (_parent)
				_parent.addChild(vp.container);
			else
				StageRef.stage.addChild(vp.container);		
		
			c.viewController.load(c, viewId, appState, viewCreateComplete);					
		}	
		
		protected function viewCreateComplete():void
		{
			var vt:ViewTransition;	
			

			if (!vp.width  || !vp.height)
			{
				vp.width = vp.container.width;
				vp.height = vp.container.height;
			}	
			
			applySettings();
			
			if (!vp.transitionPreset)
				vp.transitionPreset = "fade";
			
			vt = new ViewTransition();
			vt.render(vp, TransitionTypes.IN);
			if (_onComplete != null)
				_onComplete();
		}
		
		private function applySettings():void
		{
			if (vp.x)
				c.x = vp.x;
			if (vp.y)
				c.y = vp.y;
			
			if (c.rotation)
				c.rotation = vp.rotation;
			
			if (vp.blendMode)
				c.blendMode = vp.blendMode;
			
			if (vp.scale)
			{
				c.scaleX = c.scaleY = vp.scale;
				c.scaleY = c.scaleY = vp.scale;
			}
			
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
			
			c.posOffsetX = vp.hPad;
			c.posOffsetY = vp.vPad;
			
			if (vp.alpha)
				c.alpha = vp.alpha;
			
			if (vp.filterPreset)
			{
				var filters:Filters = new Filters();
				filters.add(c, vp.filterPreset);
			}
		}
	}
}