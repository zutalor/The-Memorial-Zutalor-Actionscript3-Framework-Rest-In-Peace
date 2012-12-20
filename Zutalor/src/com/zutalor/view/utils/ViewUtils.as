package com.zutalor.view.utils 
{
	import com.zutalor.application.Application;
	import com.zutalor.events.UIEvent;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.Singleton;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewProperties;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.ui.Mouse;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewUtils extends EventDispatcher
	{
		public static const KEEP:String = "keep";
		public static const SCALE:String = "scale";
		public static const RESIZE_TO_STAGE:String = "resizeToStage";
		public static const FIT_TO_STAGE:String = "fitToStage";
		
		private var views:NestedPropsManager;
		private static var _viewUtils:ViewUtils;

		public function ViewUtils() 
		{
			Singleton.assertSingle(ViewUtils);
			views = ViewController.presets;
		}
		
		public static function gi():ViewUtils
		{
			if (!_viewUtils)
				_viewUtils = new ViewUtils();
			
			return _viewUtils;
		}
				
		public function onStageResize(e:Event = null):void
		{	
			Mouse.show();
			Scale.calcAppScale(StageRef.stage, Application.settings.designWidth, Application.settings.designHeight);
			Scale.constrainAppScaleRatio();
			arrangeViewContainers();
		}
		
		public function arrangeViewContainers():void
		{
			var c:*;
			var vp:ViewProperties;
			var n:int;			
			
			n = StageRef.stage.numChildren;
			for (var i:int = 0; i < n; i++)
			{
				c = StageRef.stage.getChildAt(i);
				
				try
				{
					vp = views.getPropsById(c.name);
					if (vp)
						vp.container.arranger.resize(vp.resizeMode);
						vp.container.arranger.alignToStage(vp.align, vp.hPad, vp.vPad);
						
				} catch (e:Error) {}
			}	
		}
			
		public function callViewContainerMethod(viewName:String, method:String, params:String):void
		{
			var vp:ViewProperties;
			
			vp = views.getPropsById(viewName); //TODO Error check
			vp.container.callContainerMethod(method, params);
		}
		
		public function callViewItemMethod(viewName:String, viewItem:String, method:String, params:String):void
		{
			var vp:ViewProperties;
			
			vp = views.getPropsById(viewName);
			vp.container.callViewItemMethod(viewItem, method, params);			
		}
		
		public function zoom(uie:UIEvent=null, type:String=null, viewName:String = null):void
		{
			var vp:ViewProperties;
			var c:*;
			var vName:String;
			var zType:String;
			var oldScrollX:Number;
			var oldScrollY:Number;
			
			if (viewName)
				vName = viewName;
			else
				vName = uie.target.name;
				
			if (type)
				zType = type;
			else
				zType = uie.type;
				
			vp = views.getPropsById(vName);			
			c = vp.container;
			
			if (zType == UIEvent.ZOOM_IN) 
			{
				c.width += c.width * .1;
				c.height += c.height * .1;
			}
			else
			{
				c.width -= c.width * .1;
				c.height -= c.height * .1;				
			}
			vp.container.contentChanged();				
		}
	}
}