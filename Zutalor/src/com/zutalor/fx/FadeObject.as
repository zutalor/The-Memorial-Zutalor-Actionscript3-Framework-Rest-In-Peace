package com.zutalor.fx
{
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class FadeObject
	{
		public static function tweenParams(dc:DisplayObject, inOut:String):Object 
		{
			var startingAlpha:Number;
			
			startingAlpha = dc.alpha;
			
			if (inOut == TransitionTypes.IN)
			{
				
				dc.alpha = 0;
				return { alpha:startingAlpha};
			}
			else
			{
				dc.alpha = startingAlpha;
				return { alpha:0};			
			}
		}		
	}

}