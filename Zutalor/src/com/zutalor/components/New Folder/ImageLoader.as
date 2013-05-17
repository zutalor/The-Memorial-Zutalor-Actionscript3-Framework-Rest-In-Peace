package com.zutalor.components.New Folder
{
	import com.zutalor.components.base.Component;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.utils.EmbeddedResources;
	import com.zutalor.view.properties.ViewItemProperties;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ImageLoader extends Component implements IComponent
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