package com.zutalor.components.web 
{
	import com.zutalor.components.base.Component;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.properties.ViewItemProperties;
	import es.xperiments.media.StageWebViewBridge;
	import es.xperiments.media.StageWebViewDisk;
	import es.xperiments.media.StageWebviewDiskEvent;
	/**
	 * ...
	 * @author G Pepos
	 */
	public class WebBridge extends Component implements IComponent
	{
		public var webView:StageWebViewBridge;
		
		public function WebBridge(name:String) 
		{
			super(containerName, width, height);
			init(width, height, url);
		}
		
		public function render(viewItemProperties:ViewItemProperties):void
		{
			super.render(viewItemProperties);
			
			// OPTIONAL BEFORE INIT OPTIONS SETTING
			//StageWebViewDisk.setDebugMode( true ); // if we need debug mode assign it before initializaton

			// StageWebViewDisk Events. First time app launches it proceses the filesystem
			// As it can take some time, depending of the filesize of the included files
			// we provide 2 events to know when process start/finish
									
			StageWebViewDisk.addEventListener(StageWebviewDiskEvent.START_DISK_PARSING, onDiskCacheStart);
			StageWebViewDisk.addEventListener(StageWebviewDiskEvent.END_DISK_PARSING, onDiskCacheEnd);
			StageWebViewDisk.initialize( StageRef.stage /*Stage instance. Required*/ );      

			function onDiskCacheStart( e:StageWebviewDiskEvent ):void{ /* Do something at process start */ }
			function onDiskCacheEnd( e:StageWebviewDiskEvent ):void
			{
				webView = new StageWebViewBridge(0, 0, width, height);
				addChild(webView);
				
				if (vip.url)
					webView.loadURL(url);
			}
		}
		
		override public function set width(n:Number):void
		{
			super.width = webView.width = n;
		}
				
		override public function set height(n:Number):void
		{
			super.height = n;
			webView.height = n;	
		}
		
		public function loadUrl(url:String):void
		{
			if (webView)
				webView.loadURL(url);
		}
		
		override public function dispose():void
		{
			webView.dispose();
			webView = null;
			super.dispose();
		}
	}
}