package com.zutalor.view 
{
	import com.greensock.TweenMax;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.Props;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ItemFade 
	{
		public function item(viewName:String, item:DisplayObject, v:Boolean = true, fade:Number=0, delay:Number = 0):void
		{
			var savedAlpha:Number;
			var vip:ViewItemProperties;
			
			if (item)
			{
				if (v != item.visible)
				{
					if (v)
					{
						item.visible = v;
						if (fade)
						{
							if (item.alpha < 1)
							{
								vip = Props.views.getItemPropsByName(viewName, item.name);
								item.alpha = vip.alpha;
							}
							TweenMax.from(item, fade, { alpha:0, delay:delay } );
						}
					}
					else
					{
						if (fade)
						{
							savedAlpha = item.alpha;
							TweenMax.to(item, fade, { alpha:0, delay:delay, onComplete:restoreAlpha, onCompleteParams:[item, savedAlpha] } );
						}
						else
							item.visible = v;
					}
				}
			}
		}
		private function restoreAlpha(item:*, alpha:Number):void
		{
			item.visible = false;
			item.alpha = alpha;
		}	
	}
}