package com.zutalor.components.embed 
{
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.utils.Resources;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Embed extends Component implements IComponent 
	{	
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super.render(viewItemProperties);
			
			var e:* = Resources.createInstance(vip.className);
			if (e is Bitmap)
				e.smoothing = true;
				
			addChild(e);	
		}
	}
}