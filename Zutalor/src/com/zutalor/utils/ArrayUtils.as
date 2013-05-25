package com.zutalor.utils
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */

	public class ArrayUtils
	{
		public static function isEqual(arr1:Array, arr2:Array) :Boolean
		{
			if (arr1.length != arr2.length) return false;
			
			for (var i:int = 0; i < arr1.length; i++)
				if (arr1[i] != arr2[i]) return false;
			
			return true;
		}
		
		public static function getIndexWithValue(a:Array, value:*= true):int
		{
			for (var i:int = 0; i < a.length; i++)
				if (a[i] == value)
					return i;
					
			return 0;
		}
		
		public static function nullValues(... rest):void
		{
			for (var r:int = 0; r < rest.length; r++)
				for (var i:int = 0; i < rest[r].length; i++)
					rest[r][i] = null;
		}
		
		public static function copy(source:Array, dest:Array):void
		{
			for (var i:int = 0; i < source.length; i++)
				dest[i] = source[i];
		}
		
		public static function fitEvenDistribution(source:Array, dest:Array, width:int, height:int, start:Number, end:Number):Array
		{
			var destIndx:int;
			var xIncr:Number;
			var lastX:Number;
			var x:Number
			
			xIncr = lastX = x = 0;
			
			if (end == int.MAX_VALUE)
				end = source.length;
				
			if (start > end)
				start = 0; // could throw an error I suppose.
				
			if (end < width)
				xIncr = width / (end - start);
			else
				xIncr = 1;
				
			for (var i:int = start; i < end - 1; i++)
			{
				dest[destIndx] = lastX;
				dest[destIndx + 1] = height - source[i];
				
				destIndx += 2;
				
				dest[destIndx] = x + xIncr;
				if (source[i + 1] < height)
					dest[destIndx + 1] =  height - source[i + 1];
				else
					dest[destIndx + 1] = 0;
					
				lastX = x + xIncr;
				x += xIncr;
				if (x >= width)
					break;
			}
			return dest;
		}
		
		public static function fitUnevenDistribution(x:Array, y:Array, dest:Array, start:int, end:int):Array
		{
			if (end == int.MAX_VALUE)
				end = x.length;
				
			if (start > end)
				start = 0; // could throw an error I suppose.
								
			for (var i:int = start; i < end - 1; i++)
			{
				dest[i] = x[i];
				dest[i + 1] = y[i];
			}
			return dest;
		}
		
		public static function linearConversion(oldValues:Array, oldMin:Number, oldMax:Number, newMin:Number, newMax:Number):Array
		{
			var ret:Array;
			
			ret = [];
			for (var i:int = 0; i < oldValues.length; i++)
				ret[i] = (((oldValues[i] - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
				
			return ret;
		}
		
		public static function compress(oldValues:Array, oldMin:Number, oldMax:Number, newMin:Number, newMax:Number, scale:Number):Array
		{
			var ret:Array;
			
			if (scale != 1)
				ret = linearConversion(oldValues, oldMin, oldMax, newMin, ((newMax - newMin) * scale) + newMin);
			else
				ret = linearConversion(oldValues, oldMin, oldMax, newMin, newMax);
			
			return ret;
		}
		
		public static function getMax(a:Array):Number
		{
			var max:Number = 0;
			
			for (var i:int = 0; i < a.length; i++)
				if (a[i] > max)
					max = a[i];
					
			return max;
		}
		
			
		public static function getMin(a:Array):Number
		{
			var min:Number = Number.MAX_VALUE;
			
			for (var i:int = 0; i < a.length; i++)
				if (a[i] < min)
					min = a[i];
					
			return min;
		}
		
		public static function mix(a:Array, b:Array, mixA:Number=1, mixB:Number=1, bOffset:uint=0):Array
		{
			var mix:Array;
			var i:uint;
			
			mix = [];
						
			for (i = 0; i < a.length; i++)
				mix[i] = a[i];
			
			for (i = 0; i < b.length; i++)
				mix[i+bOffset] = (mix[i+ bOffset] * mixA) +  (b[i] * mixB);
			
			return mix;
		}
				
		public static function addNoise(data:Array, min:Number, max:Number, iterations:int=1, fallOff:Number=1, probability:Number=1):void
		{
			var noise:Number;
			var fade:Number;
			
			fade = 1;
			for (var c:int = 0; c < data.length; c++)
				if (probability == 1 || MathG.bool(.2))
				{
					fade = 1;
					for (var i:int = 0; i < iterations; i++)
					{
						noise = MathG.randFloat(min, max) * fade;
						data[c] += noise;
						fade *= fallOff;
					}
				}
		}
		
		public static function shuffle(a:Array, startIndex:int = 0, endIndex:int = 0):void
		{
			if (endIndex == 0)
				endIndex = a.length-1;
			
			for (var i:int = endIndex; i > startIndex; i--)
			{

				var randomNumber:int = Math.floor(Math.random() * (1+endIndex-startIndex)) + startIndex;
				var tmp:* = a[i];
				a[i] = a[randomNumber];
				a[randomNumber] = tmp;
			}
		}
	}
}