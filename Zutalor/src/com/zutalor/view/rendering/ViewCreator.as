package com.zutalor.view.rendering
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.Container;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.filters.Filters;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.positioning.Aligner;
	import com.zutalor.positioning.Arranger;
	import com.zutalor.transition.TransitionTypes;
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
			var Klass:Class;
			
			if (!viewId)
				ShowError.fail(ViewCreator,"View Id cannot be null: " + viewId);

			_onComplete = onComplete;
			vp = ViewController.presets.getPropsById(viewId);
			
			Klass = Plugins.getClass(Container.VIEW_CONTAINER);
			vp.container = c = new Klass(vp.name);
			
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
			var arranger:Arranger;
			
			arranger = new Arranger();
			if (!vp.width  || !vp.height)
			{
				vp.width = vp.container.width;
				vp.height = vp.container.height;
			}
			
			applySettings();
			
			if (!vp.transitionPreset)
				vp.transitionPreset = "fade";
			
			arranger.resize(vp.container, vp.resizeMode);
			arranger.alignToStage(vp.container, vp.align, vp.hPad, vp.vPad);
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