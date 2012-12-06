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
			super(name);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super.render(viewItemProperties);			
			StageWebViewDisk.addEventListener(StageWebviewDiskEvent.START_DISK_PARSING, onDiskCacheStart);
			StageWebViewDisk.addEventListener(StageWebviewDiskEvent.END_DISK_PARSING, onDiskCacheEnd);
			StageWebViewDisk.initialize( StageRef.stage);      

			function onDiskCacheStart( e:StageWebviewDiskEvent ):void{  }
		
		}
		
		public function onDiskCacheEnd( e:StageWebviewDiskEvent ):void
		{
			webView = new StageWebViewBridge(0, 0, int(vip.width), int(vip.height));
			addChild(webView);
			
			if (vip.path)
				webView.loadLocalURL(vip.url);
			else if (vip.url)
				webView.loadURL(vip.url);
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
	
/*
 * 
 * This is a mod of StageWebViewDiskBrige. Of course it would be better to extend the class...yet it's a f static.
 * 
		public static function getFilePath( url : String ) : String
		{
			var fileName : String = "";
			switch( true )
			{
				case url.indexOf( PROTOCOL_APP_LINK ) != -1:
					fileName = url.split( PROTOCOL_APP_LINK )[1];
					return _appCacheFile.resolvePath( getWorkingDir() + '/' + fileName ).nativePath;
					break;
				case url.indexOf( PROTOCOL_DOC_LINK ) != -1:
					fileName = url.split( PROTOCOL_DOC_LINK )[1];
					return File.documentsDirectory.resolvePath( fileName ).nativePath;
					break;
				default: // MOD By Geoff 
					fileName = url;
					return File.applicationDirectory.resolvePath( fileName ).nativePath;
					//throw new Error( "StageWebViewDisk.getFilePath( url ) :: You mus provide a valid protocol applink:/ or doclink:/" );
					break;
			}
		}
*/