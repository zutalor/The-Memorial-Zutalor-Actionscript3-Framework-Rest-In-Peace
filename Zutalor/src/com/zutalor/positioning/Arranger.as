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
		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "vertical";
		public static const GRID:String = "grid";
		
		private var aligner:Aligner;
		
		public function Arranger()
		{
			aligner = new Aligner();
		}
				
		public function alignToStage(obj:Object, align:String, hPad:int, vPad:int):void
		{
			var sw:Number;
			var sh:Number;
			
			sw = StageRef.stage.stageWidth;
			sh = StageRef.stage.stageHeight;
			
			if (align)
				aligner.alignObject(obj, sw, sh, align, hPad, vPad);
		}
		
		public function resize(obj:ContainerObject, resizeMode:String):void
		{
			var fillRect:Boolean;
			
			switch (resizeMode)
			{
				case SCALE :
					obj.scaleX = obj.scaleY = Scale.curAppScale;
					break;
				case RESIZE_TO_STAGE :
					obj.width = StageRef.stage.stageWidth;
					obj.height = StageRef.stage.stageHeight;
					break;
			}
		}
		
		public function align(obj:Object, align:String, width:Number, height:Number, hPad:Number = 0, vPad:Number = 0):void
		{
			aligner.alignObject(obj, width, height, align, hPad, vPad);
		}
	}
}