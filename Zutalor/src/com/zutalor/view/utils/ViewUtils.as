package com.zutalor.view.utils
{
	import com.zutalor.application.Application;
	import com.zutalor.events.UIEvent;
	import com.zutalor.positioning.Arranger;
	import com.zutalor.properties.NestedPropsManager;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewProperties;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ViewUtils
	{
		public static const KEEP:String = "keep";
		public static const SCALE:String = "scale";
		public static const RESIZE_TO_STAGE:String = "resizeToStage";
		public static const FIT_TO_STAGE:String = "fitToStage";
		
		private var views:NestedPropsManager;
		private var arranger:Arranger;


		public function ViewUtils()
		{
				
			arranger = new Arranger();
			views = ViewController.presets;
		}
		
		public function calcScale():void
		{
			Scale.calcAppScale(StageRef.stage, Application.settings.designWidth, Application.settings.designHeight);
			Scale.constrainAppScaleRatio();
		}
		
		public function onStageResize(e:Event = null):void
		{
			Mouse.show();
			calcScale();
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
						arrangeContainer();
						
				} catch (e:Error) {}
			}
			
			function arrangeContainer():void
			{
				var rect:Rectangle;
				
				arranger.resize(vp.container, vp.resizeMode);
				rect = new Rectangle(0, 0, vp.container.width * Scale.curAppScale, 
													vp.height * Scale.curAppScale);
				
				arranger.alignToStage(rect, vp.align, vp.hPad, vp.vPad);
				vp.container.x = rect.x;
				vp.container.y = rect.y;
			}
		}
	}
}