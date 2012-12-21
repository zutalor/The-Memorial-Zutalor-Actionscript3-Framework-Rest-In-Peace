package com.zutalor.transition
{

	import com.zutalor.containers.ViewContainer;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ScaleIt
	{
		
		public static function tweenParams(dc:ViewContainer, inOut:String, xVal:Number, yVal:Number):Object 
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