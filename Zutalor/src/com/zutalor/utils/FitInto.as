package com.zutalor.utils 
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author G
	 */
	public class FitInto 
	{
		
		public function FitInto() 
		{
			
		}
		public static function rect(displayObject : DisplayObject, rectangle : Rectangle, fillRect : Boolean = true, align : String = "C", applyTransform : Boolean = true) : Matrix
        {
            var matrix : Matrix = new Matrix();
             
            var wD : Number = displayObject.width / displayObject.scaleX;
            var hD : Number = displayObject.height / displayObject.scaleY;
             
            var wR : Number = rectangle.width;
            var hR : Number = rectangle.height;
             
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
                case Alignment.LEFT :
                case Alignment.TOP_LEFT :
                case Alignment.BOTTOM_LEFT :
                    tX = 0.0;
                    break;
                     
                case Alignment.RIGHT :
                case Alignment.TOP_RIGHT :
                case Alignment.BOTTOM_RIGHT :
                    tX = w - wR;
                    break;
                     
                default :                  
                    tX = 0.5 * (w - wR);
            }
             
            switch(align)
            {
                case Alignment.TOP :
                case Alignment.TOP_LEFT :
                case Alignment.TOP_RIGHT :
                    tY = 0.0;
                    break;
                     
                case Alignment.BOTTOM :
                case Alignment.BOTTOM_LEFT :
                case Alignment.BOTTOM_RIGHT :
                    tY = h - hR;
                    break;
                     
                default :                  
                    tY = 0.5 * (h - hR);
            }
             
            matrix.scale(s, s);
            matrix.translate(rectangle.left - tX, rectangle.top - tY);
             
            if(applyTransform)
            {
                displayObject.transform.matrix = matrix;
            }
             
            return matrix;
        }
	}

}