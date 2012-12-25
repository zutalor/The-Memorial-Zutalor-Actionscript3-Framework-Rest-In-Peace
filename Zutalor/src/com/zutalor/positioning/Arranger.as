package com.zutalor.positioning
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Arranger 
	{	
		public static const SCALE:String = "scale";
		public static const KEEP:String = "keep";
		public static const RESIZE_TO_STAGE:String = "resizeToStage";
		public static const FIT_TO_STAGE:String = "fitToStage";
		public static const STRETCH_TO_STAGE:String = "stretchToStage";
		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "vertical";
		public static const GRID:String = "grid";		
		
		private var aligner:Aligner;
		private var obj:ContainerObject;
		
		public function Arranger(containerObject:ContainerObject)
		{
			obj = containerObject;
			aligner = new Aligner();
		}
				
		public function alignToStage(align:String, hPad:int, vPad:int):void
		{
			var sw:Number;
			var sh:Number;
			
			sw = StageRef.stage.stageWidth;
			sh = StageRef.stage.stageHeight;
			
			if (align)
				aligner.alignObject(obj, sw, sh, align, hPad, vPad);
		}
		
		public function resize(resizeMode:String):void
		{
			var fillRect:Boolean;
			if (resizeMode == STRETCH_TO_STAGE)
				fillRect = true;
			
			switch (resizeMode)
			{
				case SCALE :
					obj.scaleX = obj.scaleY = Scale.curAppScale;						
					break;
				case RESIZE_TO_STAGE :
					obj.width = StageRef.stage.stageWidth;				
					obj.height = StageRef.stage.stageHeight;
					break;
				case FIT_TO_STAGE :
				case STRETCH_TO_STAGE :
					aligner.alignObject(obj, StageRef.stage.stageWidth, StageRef.stage.stageHeight, "fit", 0, 0, fillRect);
					break;
			}
		}
		
		public function align(align:String, width:Number, height:Number, hPad:Number = 0, vPad:Number = 0, filRect:Boolean = false):void
		{
			aligner.alignObject(obj, width, height, align, hPad, vPad, filRect);
		}
	}
}