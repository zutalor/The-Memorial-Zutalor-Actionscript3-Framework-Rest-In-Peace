package com.zutalor.components.embed 
{
	import com.zutalor.components.base.Component;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.utils.EmbeddedResources;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Embed extends Component implements IComponent 
	{	
		public function Embed(name:String)
		{
			super(name);
		}

		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super.render(viewItemProperties);
			
			var e:* = EmbeddedResources.createInstance(vip.className);
			if (e is Bitmap)
				e.smoothing = true;
				
			addChild(e);	
		}
	}
}