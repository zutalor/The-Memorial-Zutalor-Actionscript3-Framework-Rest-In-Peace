package com.zutalor.utils 
{
	/**
	 * uk.soulwire.utils.display.DisplayUtils
	 * 
	 * @version v1.0
	 * @since May 26, 2009
	 * 
	 * @author Justin Windle
	 * @see http://blog.soulwire.co.uk
	 * 
	 * 
	 * Licensed under a Creative Commons Attribution 3.0 License
	 * http://creativecommons.org/licenses/by/3.0/
	 */
	 
	import com.zutalor.containers.ViewContainer;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;

	public class DisplayUtils 
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
		//---------------------------------------------------------------------------
		//------------------------------------------------------------ PUBLIC METHODS
		
		/**
		 * Fits a DisplayObject into a rectangular area with several options for scale 
		 * and  This method will return the Matrix required to duplicate the 
		 * transformation and can optionally apply this matrix to the DisplayObject.
		 * 
		 * @param displayObject
		 * 
		 * The DisplayObject that needs to be fitted into the Rectangle.
		 * 
		 * @param rectangle
		 * 
		 * A Rectangle object representing the space which the DisplayObject should fit into.
		 * 
		 * @param fillRect
		 * 
		 * Whether the DisplayObject should fill the entire Rectangle or just fit within it. 
		 * If true, the DisplayObject will be cropped if its aspect ratio differs to that of 
		 * the target Rectangle.
		 * 
		 * @param align
		 * 
		 * The alignment of the DisplayObject within the target Rectangle. Use a constant from 
		 * the DisplayUtils class.
		 * 
		 * @param applyTransform
		 * 
		 * Whether to apply the generated transformation matrix to the DisplayObject. By setting this 
		 * to false you can leave the DisplayObject as it is but store the returned Matrix for to use 
		 * either with a DisplayObject's transform property or with, for example, BitmapData.draw()
		 */

		public static function fitIntoRect(displayObject : DisplayObject, width:Number, height:Number, align : String = "center", hPad:int = 0, vPad:int = 0, fillRect : Boolean = false, applyTransform : Boolean = true) : Matrix
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
			return matrix;
		}
		
		public static function alignInRect(displayObject : DisplayObject, width:Number, height:Number, align : String = "center", hPad:int = 0, vPad:int = 0):void
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
