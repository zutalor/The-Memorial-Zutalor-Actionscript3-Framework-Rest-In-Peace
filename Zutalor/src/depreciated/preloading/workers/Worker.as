package depreciated.preloading.workers
{
	import com.zutalor.preloading.Asset;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import com.zutalor.preloading.Asset;
	import com.zutalor.preloading.events.AssetCompleteEvent;
	import com.zutalor.preloading.events.AssetErrorEvent;
	import com.zutalor.preloading.events.AssetOpenEvent;
	import com.zutalor.preloading.events.AssetProgressEvent;
	import com.zutalor.preloading.events.AssetStatusEvent;		

	/**
	 * Dispatched when the worker has completed downloading the asset.
	 * 
	 * @eventType com.mccann.floss.preloading.events.AssetCompleteEvent
	 */
	[Event("assetComplete", type="com.mccann.floss.preloading.machinist.events.AssetCompleteEvent")]
	
	/**
	 * Dispatched when the loader starts loading the asset.
	 * 
	 * @eventType com.mccann.floss.preloading.events.AssetOpenEvent
	 */
	[Event("assetOpen", type="com.mccann.floss.preloading.events.AssetOpenEvent")]
	
	/**
	 * Dispatched on progress from the loader that is loading the asset.
	 * 
	 * @eventType com.mccann.floss.preloading.events.AssetProgressEvent
	 */
	[Event("assetProgress", type="com.mccann.floss.preloading.events.AssetProgressEvent")]
	
	/**
	 * Dispatched when there is an error loading an asset.
	 * 
	 * @eventType com.mccann.floss.preloading.events.AssetErrorEvent
	 */
	[Event("assetError", type="com.mccann.floss.preloading.events.AssetErrorEvent")]
	
	/**
	 * Dispatched when an HTTPStatus event occurs from the internal loader. This only dispatches
	 * for HTTP status codes other than 0 and 200.
	 * 
	 * @eventType com.mccann.floss.preloading.events.AssetStatusEvent
	 */
	[Event("assetStatus", type="com.mccann.floss.preloading.events.AssetStatusEvent")]
	
	/**
	 * Dispatched when a security error happens while attempting to load the item.
	 * 
	 * @eventType flash.events.SecurityErrorEvent
	 */
	[Event("securityError", type="flash.events.SecurityErrorEvent")]
	
	/**
	 * The Worker class is a generic worker that implements base logic for loading 
	 * an Asset. Most subclasses don't need to override all of the logic in this
	 * class.
	 * 
	 * <p>The worker provides default behavior like listening to events from the internal
	 * loader and taking care of the callbacks, and routing the events
	 * to the associated PreloadController.</p>
	 * 
	 * <p>This worker class cannot be used directly, it must be subclassed. You
	 * must override the "load" method and implement your own logic to prepare
	 * the internal loader and request objects.</p>
	 *
	 * <p>Worker subclasses must also be registered with the WorkerInstances class. An Asset
	 * uses WorkerInstances to get a worker for it's type being loaded.</p>
	 *
	 * <p>Here is a snippet taken from the BitmapWorker class that shows overriding the load method
	 * and setting up the internal loader and request properties.</p>
	 * 
	 * <listing>	
	 * override public function load(asset:Asset):void
	 * {
	 *    this.asset = asset;
	 *    request = new URLRequest(asset.source);
	 *    loader = new Loader();
	 * 	  loader.contentLoaderInfo.addEventListener(Event.OPEN, super.onOpen);
	 * 	  loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, super.onProgress);
	 * 	  loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, super.onHTTPStatus);
	 * 	  loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, super.onIOLoadError);
	 * 	  loader.contentLoaderInfo.addEventListener(IOErrorEvent.DISK_ERROR, super.onIOLoadError);
	 * 	  loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, super.onIOLoadError);
	 * 	  loader.contentLoaderInfo.addEventListener(IOErrorEvent.VERIFY_ERROR, super.onIOLoadError);
	 * 	  loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, super.onSecurityError);
	 * 	  loader.contentLoaderInfo.addEventListener(Event.COMPLETE, super.onComplete);
	 * 	  start(); //kicks off the loading, default loading logic is in the Worker class.
	 * }
	 * </listing>
	 * 
	 * <p>See the source code in any other worker in this package for subclassing examples.</p>
	 * 
	 * <script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	public class Worker extends EventDispatcher
	{

		/**
		 * The asset this worker is loading.
		 */
		protected var asset:Asset;
		
		/**
		 * Internal loader used for loading the asset.
		 * 
		 * <p>This is untyped so that any type of loader can be used. The loader you
		 * use must have a "load" method declared on it that accepts a URLRequest.</p>
		 */
		protected var loader:*;
		
		/**
		 * The URLRequest for the asset.
		 */
		protected var request:URLRequest;
		
		/**
		 * @private
		 * 
		 * The bytes loaded
		 */
		public var bytesLoaded:Number = -1;
		
		/**
		 * @private
		 * 
		 * The bytes total
		 */
		public var bytesTotal:Number = -1;
		
		/**
		 * The loader context for the asset being loaded.
		 */
		public var loaderContext:LoaderContext;

		/**
		 * Load an asset.
		 * 
		 * <p>This will throw an exception if you do not override the method.</p>
		 * 
		 * @param asset the asset to load.
		 */
		public function load(asset:Asset):void
		{
			throw new Error("You must extend Worker#load and implement your own logic");
		}
		
		/**
		 * Starts loading the internal loader instance.
		 * 
		 * <p>The loader you set for the internal loader must have a "load" method
		 * defined and accept a URLRequest</p>
		 */
		public function start():void
		{
			if(!request) throw new Error("The internal request object was null, you need to prepate the request object in your subclass.");
			if(!loader) throw new Error("The internal loader object was null, you need to prepate the loader object in your subclass");
			if((loader is Loader)&&loaderContext)loader.load(request,loaderContext);
			else loader.load(request);
		}
				
		/** 
		 * The event handler for the internal loaders open event.
		 * 
		 * @param e The open event from the internal loader.
		 */
		protected function onOpen(e:Event):void
		{
			dispatchEvent(new AssetOpenEvent(AssetOpenEvent.OPEN, asset));
		}
		
		/**
		 * The event handler for the internal loaders progress.
		 * 
		 * @param pe The progress event from the internal loader.
		 */
		protected function onProgress(pe:ProgressEvent):void
		{
			this.bytesLoaded = pe.bytesLoaded;
			this.bytesTotal = pe.bytesTotal;
			dispatchEvent(new AssetProgressEvent(AssetProgressEvent.PROGRESS,asset));
		}
		
		/**
		 * The event handler for the internal loaders http status event.
		 * 
		 * @param hse The status event from the internal loader.
		 */
		protected function onHTTPStatus(hse:HTTPStatusEvent):void
		{
			if(hse.status != 0 && hse.status != 200)
			{
				dispatchEvent(new AssetStatusEvent(AssetStatusEvent.STATUS, asset, hse.status));
				removeEventListeners();
				asset = null;
			}
		}
		
		/**
		 * The event handler for the internal loaders error event.
		 * 
		 * @param e The error event from the internal loader.
		 */
		protected function onIOLoadError(e:IOErrorEvent):void
		{
			removeEventListeners();
			dispatchEvent(new AssetErrorEvent(AssetErrorEvent.ERROR, asset));
			asset = null;
		}
		
		/**
		 * The event handler for the internal loaders security error event.
		 * 
		 * @param se The security error event from the internal loader.
		 */
		protected function onSecurityError(se:SecurityErrorEvent):void
		{
			removeEventListeners();
			dispatchEvent(se);
			asset = null;
		}
		
		/**
		 * The event handler for the internal loaders complete event.
		 * 
		 * @param e The event from the internal loaders complete event.
		 */
		protected function onComplete(e:Event):void
		{
			removeEventListeners();
			asset.data = loader;
			dispatchEvent(new AssetCompleteEvent(AssetCompleteEvent.COMPLETE, asset));
			asset = null;
			try { loader.close(); loader = null; } catch (error:*) { }
		}
		
		/**
		 * Close the internal loader.
		 */
		public function close():void
		{
			try { loader.close(); loader = null; } catch (error:*) { }
		}
		
		/**
		 * @private
		 * 
		 * Removes event listeners from the internal loader.
		 */
		protected function removeEventListeners():void
		{
			if(!loader) return;
			loader.removeEventListener(Event.OPEN, onOpen);
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOLoadError);
			loader.removeEventListener(IOErrorEvent.DISK_ERROR, onIOLoadError);
			loader.removeEventListener(IOErrorEvent.NETWORK_ERROR, onIOLoadError);
			loader.removeEventListener(IOErrorEvent.VERIFY_ERROR, onIOLoadError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}
		
		/**
		 * Dispose of this worker instance.
		 */
		public function dispose():void
		{
			removeEventListeners();
			close();
			bytesLoaded = NaN;
			bytesTotal = NaN;
			asset = null;
			loader = null;
			request = null;
		}
	}
}