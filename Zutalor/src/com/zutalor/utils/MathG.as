package com.zutalor.utils 
{
	import flash.geom.Point;
	import flash.utils.getTimer;
	/*
	 * A collection of static methods for common math operations. Some methods by Lee Brimlow.
	*/
	
	public class MathG 
	{

		// Returns a random float
		public static function randFloat(min:Number,max:Number=NaN):Number 
		{
			if (isNaN(max)) 
			{ 
				max = min; 
				min = 0; 
			}
			return Math.random() * (max - min) + min;
		}
		
		// Returns a random integer
		public static function rand(min:Number,max:Number=NaN):int 
		{
			if (isNaN(max)) 
			{ 
				max = min; 
				min = 0; 
			}
			return Math.floor(Math.random() * (1 + max - min)) + min;
		}
		
		public static function truncate(val:Number, decimalPlaces:uint):Number{
            var multiplier:uint = Math.pow(10, decimalPlaces);
            var truncatedVal:Number = val*multiplier;

            if (truncatedVal > int.MAX_VALUE){

                return Number(truncatedVal.toFixed(decimalPlaces));
            }        
			trace(int(truncatedVal) / multiplier);
            return int(truncatedVal)/multiplier;

		}
		
		// Converts radians to degrees
		public static function toDeg(rad:Number):Number
		{
			return rad/Math.PI*180;
		}
		
		// Converts degrees to radians
		public static function toRad( deg:Number ):Number
		{
			return deg/180*Math.PI;
		}
		
		// Returns true or false based on chance
		public static function bool(chance:Number=0.5):Boolean
		{
			return (Math.random() < chance) ? true : false;
		}
				
		public static function linearConversion(oldValue:Number, oldMin:Number, oldMax:Number, newMin:Number, newMax:Number):Number
		{
			return (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin; 
		}
		
		public static function GetMidPoint(fromX:Number, fromY:Number, toX:Number, toY:Number):Point
		{
			var p:Point = new Point();
			p.x = (toX + fromX) >> 1;
			p.y = (toY + fromY) >> 1;
			return p;
		}
		public static function GetPointOnLine(fromX:Number, fromY:Number, toX:Number, toY:Number, prct:Number):Point
		{
			var p:Point = new Point();
			var dx:Number = toX - fromX;
			var dy:Number = toY - fromY;
			var length:Number = Math.sqrt(dx * dx + dy * dy) * prct; 
			var angle:Number = Math.atan2(dy, dx);
			
			p.x = fromX + Math.cos(angle) * length;
			p.y = fromY + Math.sin(angle) * length;
		
			return p;
		}
		public static function calcDistance(fromX:Number, fromY:Number, toX:Number, toY:Number):Number
		{
			var dx:Number;
			var dy:Number;
			
			dx = toX - fromX;
			dy = toY - fromY;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		/*
			An idea of how this could be used: you have a chessboard graphic and want to know which
			square was tapped, numbered 0 through number of squares - 1. Rather than creating an object
			for each square and listening for a tap on each one, send this the tap x/y pixel position,
			the number of squares in each row and column and the width and the nheight of your graphical
			viewport in pixels.
		*/
		
		public static function gridIndexQuantizer(x:int, y:int, cols:int, rows:int, width:int, height:int):GridValues
		{
			var pxPerRow:Number;
			var pxPerCol:Number;
			var r:int;
			var c:int;
			var value:GridValues;
			
			value = new GridValues();			
			pxPerRow = height / rows;
			pxPerCol = width / cols;

			for (c = 1; c <= cols; c++)			
				if (x < pxPerCol * c)
					break;
					
			for (r = 1; r <= rows; r++)
				if (y < pxPerRow * r)
					break;
					
			value.col = --c;
			value.row = --r;
			value.index = r * cols + c;
			return value;
		}	
	}
}