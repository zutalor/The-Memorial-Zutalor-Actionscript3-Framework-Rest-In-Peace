package com.zutalor.containers.utils
{
	import com.zutalor.utils.Aligner;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.properties.ViewProperties;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ViewContainerAligner 
	{	
		public static const SCALE:String = "scale";
		public static const KEEP:String = "keep";
		public static const RESIZE_TO_STAGE:String = "resizeToStage";
		public static const FIT_TO_STAGE:String = "fitToStage";
		
		private var _aligner:Aligner;
		
		public function ViewContainerAligner()
		{
			_aligner = new Aligner();
		}
		
		public function align(vp:ViewProperties):void
		{				
			if (vp.container)
			{
				resize(vp);
				if (vp.align)
					_aligner.alignObject(vp.container, StageRef.stage.stageWidth, StageRef.stage.stageHeight, vp.align, vp.hPad, vp.vPad);
			}
		}
		
		private function resize(vp:ViewProperties):void
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
					vp.container.alignContainer();
					break;
				case KEEP :
				default :
					vp.container.scaleX = vp.container.scaleY = 1;
					vp.container.width = vp.width;
					vp.container.height = vp.height;
					break;
			}
		}
	}
}