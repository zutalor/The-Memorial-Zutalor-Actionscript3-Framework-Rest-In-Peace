package com.zutalor.view.transition 
{
	import com.greensock.TweenMax;
	import com.zutalor.view.properties.ViewItemProperties;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ItemFX 
	{
		public static function fade(viewName:String, item:DisplayObject, v:Boolean = true, fade:Number=0, delay:Number = 0):void
		{
			var savedAlpha:Number;
			var vip:ViewItemProperties;
		
			if (item)
			{
				if (v)
				{					
					if (fade)
					{
						item.visible = true;
						savedAlpha = item.alpha;
						item.alpha = 0;
						TweenMax.from(item, fade, { alpha:savedAlpha, delay:delay } );
					}
					else
						item.visible = true;
						
						
				}
				else
				{
					if (fade)
					{
						savedAlpha = item.alpha;
						TweenMax.to(item, fade, { alpha:0, delay:delay, onComplete:restoreAlpha, onCompleteParams:[item, savedAlpha] } );
					}
					else
						item.visible = false;
				}
			}
		}
		
		private static function restoreAlpha(item:*, alpha:Number):void
		{
			item.visible = false;
			item.alpha = alpha;
		}	
	}
}