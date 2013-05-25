package com.zutalor.positioning
{
	public class Aligner
	{
		public static const BOTTOM : String = "bottom";
		public static const BOTTOM_LEFT : String = "bottom-left";
		public static const BOTTOM_RIGHT : String = "bottom-right";
		public static const BOTTOM_ONE_FIFTH:String = "bottom-one-fifth";
		public static const BOTTOM_TWO_FIFTH:String = "bottom-two-fifth";
		public static const BOTTOM_THREE_FIFTH:String = "bottom-three-fifth";
		public static const BOTTOM_FOUR_FIFTH:String = "bottom-four-fifth";

		public static const LEFT : String = "left";
		public static const CENTER : String = "center";
		public static const RIGHT : String = "right";
		public static const TOP : String = "top";
		public static const TOP_LEFT : String = "top-left";
		public static const TOP_RIGHT : String = "top-right";
		public static const TOP_CENTER : String = "top-center";
		public static const BOTTOM_CENTER : String = "bottom-center";
				
		public function alignObject(object : Object, width:Number, height:Number, align : String = "center", hPad:Number = 0, vPad:Number = 0):Number
		{
			var scaleX:Number;
			var scaleY:Number;
			var scale:Number;
			
			var wD : Number = object.width;
			var hD : Number = object.height;
			
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
			
			if (!scale)
				scale = 1;
			
			var colSize:Number = wR / 5;
			switch(align) //x
			{
				case LEFT :
				case TOP_LEFT :
				case BOTTOM_LEFT :
				case BOTTOM :
					tX = 0.0;
					break;
				case BOTTOM_CENTER :
				case TOP_CENTER :
					tX = (wR * + wD) * .5;
					break;
				case BOTTOM_ONE_FIFTH :
					tX = colSize - (wD * .5);
					break;
				case BOTTOM_TWO_FIFTH :
					tX = (colSize * 2) - (wD * .5);
					break;
				case BOTTOM_THREE_FIFTH :
					tX = (colSize * 3) - (wD * .5);
					break;
				case BOTTOM_FOUR_FIFTH :
					tX = (colSize * 4) - (wD * .5);
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
				case TOP_CENTER :
					tY = 0.0;
					break;
				case BOTTOM :
				case BOTTOM_CENTER :
				case BOTTOM_LEFT :
				case BOTTOM_RIGHT :
				case BOTTOM_LEFT :
				case BOTTOM_RIGHT :
				case BOTTOM_ONE_FIFTH :
				case BOTTOM_TWO_FIFTH :
				case BOTTOM_THREE_FIFTH :
				case BOTTOM_FOUR_FIFTH :
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
			
				
			object.x = tX;
			object.y = tY;
			
			return scale;
		}
	}
}
