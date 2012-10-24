package com.zutalor.fx
{
	import com.greensock.TweenMax;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Blur
	{
		private static var _bX:int = 100;
		private static var _bY:int = 100;
		private static var _bQ:int = 5;
		
		public static function tweenParams(dc:DisplayObject, inOut:String):Object
		{
			if (inOut == TransitionTypes.IN)
			{
				TweenMax.to(dc, 0, { blurFilter: { blurX:_bX, blurY:_bY, blurQuality:_bQ } } );
				return { blurFilter: { blurX:0, blurY:0, blurQuality:_bQ }};
			}
			else 
			{
				return { blurFilter: { blurX:_bX, blurY:_bY, blurQuality:_bQ }};
			}
		}
		
	}

}