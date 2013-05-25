package com.zutalor.components.loadedImage
{
	import com.greensock.loading.LoaderMax;
	import com.zutalor.components.base.Component;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.utils.EmbeddedResources;
	import com.zutalor.view.properties.ViewItemProperties;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Geoff
	 */
	public class LoadedImage extends Component implements IComponent
	{
		private var loader:Loader;
		
		public function LoadedImage(name:String)
		{
			super(name);
		}

		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var fileRequest:URLRequest;
			
			super.render(viewItemProperties);			
			
			loader = new Loader();
			fileRequest = new URLRequest(vip.url);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad, false, 0, true);
			loader.load(fileRequest);
		}
		
		private function onLoad(e:Event):void
		{
			var bm:Bitmap;
			loader.removeEventListener(Event.COMPLETE, onLoad);
			bm = loader.content as Bitmap;
			bm.smoothing = true;
			addChild(bm);
		}
	}
}