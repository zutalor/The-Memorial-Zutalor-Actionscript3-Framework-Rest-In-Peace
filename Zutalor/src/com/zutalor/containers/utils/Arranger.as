package com.zutalor.containers.utils
{
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.Container;
	import com.zutalor.events.ContainerEvent;
	import com.zutalor.utils.Aligner;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import flash.display.DisplayObject;
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

		public function autoArrangeChildren(options:Object):void
		{
			var i:int = 0;
			var width:int = 0;
			var height:int = 0;
			var padding:Number = 0;
			var orientation:String = HORIZONTAL;
			var child:DisplayObject;
							
			if ("padding" in options)
				padding = options["padding"];
				
			if ("orientation" in options)	
				orientation = options["orientation"];
			
				
			for (i = 0; i < obj.numChildren; i++)
			{
				if (orientation == HORIZONTAL)
				{
					if (padding && padding < 1)
						padding *= width; 
					
					if (i) 
						width += padding;
					
					child = obj.getChildAt(i);
					child.x = width;
					width += child.width;
				}
				else
				{
					if (padding && padding < 1)
						padding *= height; 

					if (i) // no front padding on first entry
						height += padding;
					
					child = obj.getChildAt(i);
					child.y = height;
					height += child.height;
				}
			}
			if (obj.numChildren)
				obj.dispatchEvent(new ContainerEvent(ContainerEvent.CONTENT_CHANGED));
		}
	}
}