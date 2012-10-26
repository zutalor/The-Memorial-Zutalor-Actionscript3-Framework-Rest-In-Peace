package com.zutalor.view 
{
	import com.greensock.easing.Quart;
	import com.greensock.TweenMax;
	import com.zutalor.containers.StandardContainer;
	import com.zutalor.events.UIEvent;
	import com.zutalor.motion.MotionUtils;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.ScrollProperties;
	import com.zutalor.properties.ViewProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.Presets;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.DisplayUtils;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.Singleton;
	import com.zutalor.utils.StageRef;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;

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
		
		private var ap:ApplicationProperties;
		private var vpm:NestedPropsManager;
		private var mu:MotionUtils;
		private var pr:Presets;
		
		private static var _viewUtils:ViewUtils;

		public function ViewUtils() 
		{
			Singleton.assertSingle(ViewUtils);
			ap = ApplicationProperties.gi();
			vpm = Props.views;
			mu = MotionUtils.gi();
			pr = Presets.gi();
		}
		
		public static function gi():ViewUtils
		{
			if (!_viewUtils)
				_viewUtils = new ViewUtils();
			
			return _viewUtils;
		}
		
		public function onContainerMouseOver(me:MouseEvent):void
		{
			var vp:ViewProperties;
			var target:DisplayObject;
			
			vp = getParentContainerProps(me.target as DisplayObject);
			
			if (vp)
			{
				if (vp.dimWhenNotActive)
					TweenMax.to(vp.container, .5, { alpha:vp.alpha } );					
			}
		}
		
		private function getParentContainerProps(target:DisplayObject):ViewProperties
		{
			var vp:ViewProperties;
			vp = vpm.getPropsById(target.name);
			if (vp)
			{
				return vp;
			}
			else
				if (target.parent == null)
				{
					return null;
				}
				else
				{
					return getParentContainerProps(target.parent);
				}
		}
		
		public function onContainerMouseOut(me:MouseEvent):void
		{
			var vp:ViewProperties;
			
			vp = vpm.getPropsById(me.target.name);
			if (vp)
			{
				if (vp.dimWhenNotActive)
					TweenMax.to(vp.container, .5, { alpha:.5 } );
			}
		}		
				
		public function arrangeAppContainers():void
		{
			var c:*;
			var vp:ViewProperties;
			var n:int;			
			
			n = Props.ap.contentLayer.numChildren;
			for (var i:int = 0; i < n; i++)
			{
				c = Props.ap.contentLayer.getChildAt(i);
				
				try
				{
					vp = vpm.getPropsById(c.name);
					if (vp)
						positionAppContainer(vp);	
						
				} catch (e:Error) {}
			}	
		}
		
		public function positionAppContainer(vp:ViewProperties):void
		{				
			if (vp.container)
			{
				resizeContainer(vp);
				positionContainer(vp);
			}
		}
		
		private function resizeContainer(vp:ViewProperties):void
		{
				switch (vp.resizeMode)
				{
					case SCALE :
						vp.container.scaleX = vp.container.scaleY = Scale.curAppScale;							
						break;
					case RESIZE_TO_STAGE :
						vp.container.width = StageRef.stage.stageWidth;				
						vp.container.height = StageRef.stage.stageHeight;
						break;
					case FIT_TO_STAGE :
					    DisplayUtils.fitIntoRect(vp.container, StageRef.stage.stageWidth, StageRef.stage.stageHeight, DisplayUtils.TOP_LEFT, 0, 0, true);
						break;
					case KEEP :
					default :
						// do nothing
						break;
				}
		}
		
		private function positionContainer(vp:ViewProperties):void
		{
			if (vp.align)
				DisplayUtils.fitIntoRect(vp.container, StageRef.stage.stageWidth, StageRef.stage.stageHeight, vp.align);
		}
		
		public function callViewContainerMethod(viewName:String, method:String, params:String):void
		{
			var vp:ViewProperties;
			
			vp = vpm.getPropsById(viewName); //TODO Error check
			vp.container.callContainerMethod(method, params);
		}
		
		public function callViewItemMethod(viewName:String, viewItem:String, method:String, params:String):void
		{
			var vp:ViewProperties;
			
			vp = vpm.getPropsById(viewName);
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
				
			vp = vpm.getPropsById(vName);			
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
			
			if (c.scaleX >= 1)
			{
				oldScrollX = vp.container.scrollPercentX
			}
			else
			{
				oldScrollX = 0;
			}
			
			if (c.scaleY >= 1)
			{
				oldScrollY = vp.container.scrollPercentY;
			}
			else
			{
				oldScrollY = 0;
			}

			vp.container.contentChanged();				
			vp.container.tweenScrollPercentX(oldScrollX);
			vp.container.tweenScrollPercentY(oldScrollY)	
			vp.container.scrollPercentX = oldScrollX;
			vp.container.scrollPercentY = oldScrollY;
		}
		
		public function updateContainerScrollPosition(scrollPreset:String):void
		{	
			var spp:ScrollProperties;
			var c:StandardContainer;
			spp = pr.scrollPresets.getPropsByName(scrollPreset);
			if (spp)
			{
				c = vpm.getPropsById(spp.viewName).container;				
				if (c)
				{
					c.tweenScrollPercentX(spp.scrollPercentX, spp.scrollTimeX, Quart.easeInOut);
					c.tweenScrollPercentY(spp.scrollPercentY, spp.scrollTimeY, Quart.easeInOut);
				}
			}
		}			
	}
}