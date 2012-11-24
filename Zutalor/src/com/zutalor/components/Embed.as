package com.zutalor.components 
{
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.utils.Resources;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Embed extends Component implements IComponent 
	{	
		override public function render(vip:ViewItemProperties):void
		{
			var e:* = Resources.createInstance(vip.className);
			if (e is Bitmap)
				e.smoothing = true;
				
			addChild(e);	
		}
	}
}