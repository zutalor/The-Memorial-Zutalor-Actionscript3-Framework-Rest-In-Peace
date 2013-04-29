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
						arranger.resize(vp.container, vp.resizeMode);
						arranger.alignToStage(vp.container, vp.align, vp.hPad, vp.vPad);
						
				} catch (e:Error) {}
			}
		}
	}
}