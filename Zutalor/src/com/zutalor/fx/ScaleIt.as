package com.zutalor.fx
{

	import com.zutalor.containers.StandardContainer;
	import com.zutalor.sprites.CenterSprite;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ScaleIt
	{
		
		public static function tweenParams(dc:StandardContainer, inOut:String, xVal:Number, yVal:Number):Object 
		{
			var OrigScaleX:Number;
			var OrigScaleY:Number;
			
			OrigScaleX = dc.scaleX;
			OrigScaleY = dc.scaleY;
							
			if (inOut == TransitionTypes.IN)
			{
				dc.sx -= xVal;
				dc.sy -= yVal;
				return { sx:OrigScaleX, sy:OrigScaleY };
			}
			else
			{
				return { }; // TODO
			}
		}		
	}

}