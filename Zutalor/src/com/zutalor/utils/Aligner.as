package com.zutalor.utils 
{
	/**
	 * uk.soulwire.utils.display.DisplayUtils
	 * 
	 * @version v1.0
	 * @since May 26, 2009
	 * 
	 * @author Justin Windle, Mod by Pepos (added fitInto and made this not a static class
	 * @see http://blog.soulwire.co.uk
	 * 
	 * 
	 * Licensed under a Creative Commons Attribution 3.0 License
	 * http://creativecommons.org/licenses/by/3.0/
	 */
	 
	import flash.display.DisplayObject;
	import flash.geom.Matrix;

	public class Aligner
	{	
		public static const BOTTOM : String = "bottom";
		public static const BOTTOM_LEFT : String = "bottom-left";
		public static const BOTTOM_RIGHT : String = "bottom-right";
		public static const LEFT : String = "left";
		public static const CENTER : String = "center";
		public static const RIGHT : String = "right";
		public static const TOP : String = "top";
		public static const TOP_LEFT : String = "top-left";
		public static const TOP_RIGHT : String = "top-right";
		public static const KEEP : String = "keep";
		public static const FIT : String = "fit";
		public static const SCALE : String = "scale";
		
		public function alignObject(displayObject:DisplayObject, width:Number, height:Number, align:String, hPad:int = 0, vPad:int = 0, fillRect:Boolean = false, applyTransfrom:Boolean = true): void
		{
			if (align == FIT)
				fitIntoRect(displayObject, width, height, align, hPad, vPad, fillRect, applyTransfrom);
			else
				alignInRect(displayObject, width, height, align, hPad, vPad);
		}
		
		private function fitIntoRect(displayObject : DisplayObject, width:Number, height:Number, align : String = "center", hPad:int = 0, vPad:int = 0, fillRect : Boolean = false, applyTransform : Boolean = true) : void
		{
			var matrix : Matrix = new Matrix();
			
			var wD : Number = displayObject.width;
			var hD : Number = displayObject.height;
			
			var wR : Number = width;
			var hR : Number = height;
			
			var sX : Number = wR / wD;
			var sY : Number = hR / hD;
			
			var rD : Number = wD / hD;
			var rR : Number = wR / hR;
			
			var sH : Number = fillRect ? sY : sX;
			var sV : Number = fillRect ? sX : sY;
			
			var s : Number = rD >= rR ? sH : sV;
			var w : Number = wD * s;
			var h : Number = hD * s;
			
			var tX : Number = 0.0;
			var tY : Number = 0.0;
			
			switch(align)
			{
				case LEFT :
				case TOP_LEFT :
				case BOTTOM_LEFT :
					tX = 0.0;
					break;
					
				case RIGHT :
				case TOP_RIGHT :
				case BOTTOM_RIGHT :
					tX = w - wR;
					break;
					
				case CENTER : 					
					tX = 0.5 * (wR - w);
					break;
				default :
					tX = 0.0;
					break;
			}
			
			switch(align)
			{
				case TOP :
				case TOP_LEFT :
				case TOP_RIGHT :
					tY = 0.0;
					break;
					
				case BOTTOM :
				case BOTTOM_LEFT :
				case BOTTOM_RIGHT :
					tY = h - hR;
					break;
					
				case CENTER : 					
					tY = 0.5 * (hR - h);
					break;
				default :
					tY = 0.0;
					break;
			}
			if (hPad)
				tX += hPad * s;
			
			if (vPad)
				tY += vPad * s;
			
				
			if (s != 1) 
			{
				matrix.scale(s, s);
				matrix.translate(tX, tY);
				
				if(applyTransform)
				{
					displayObject.transform.matrix = matrix;
				}
			}
		}
		
		private function alignInRect(displayObject : DisplayObject, width:Number, height:Number, align : String = "center", hPad:int = 0, vPad:int = 0):void
		{
			var scaleX:Number;
			var scaleY:Number;
			var scale:Number;
			
			var wD : Number = displayObject.width;
			var hD : Number = displayObject.height;
			
			var wR : Number = width;
			var hR : Number = height;
									
			var tX : Number = 0.0;
			var tY : Number = 0.0;

			if (wD + hPad > width)
				scaleX = width / (wD + hPad);
			
			if (hD + vPad > height)
				scaleY = height / (hD + vPad);
				
			if (scaleY < scaleX)
				scale = scaleY;
			else
				scale = scaleX;
			
			if (scale)
				displayObject.scaleX = displayObject.scaleY = scale;
			else
				scale = 1;
			
			switch(align)
			{
				case LEFT :
				case TOP_LEFT :
				case BOTTOM_LEFT :
					tX = 0.0;
					break;
					
				case RIGHT :
				case TOP_RIGHT :
				case BOTTOM_RIGHT :
					tX = wR - wD
					break;
					
				default : 					
					tX = 0.5 * (wR - wD);
					break;
			}
			
			switch(align)
			{
				case TOP :
				case TOP_LEFT :
				case TOP_RIGHT :
					tY = 0.0;
					break;
					
				case BOTTOM :
				case BOTTOM_LEFT :
				case BOTTOM_RIGHT :
					tY = hR - hD;
					break;
					
				default : 					
					tY = 0.5 * (hR - hD);
					break;
			}
			if (hPad)
				tX += (hPad * scale);
			
			if (vPad)
				tY += (vPad * scale);
			
				
			displayObject.x = tX;
			displayObject.y = tY;
		}
	}
}
