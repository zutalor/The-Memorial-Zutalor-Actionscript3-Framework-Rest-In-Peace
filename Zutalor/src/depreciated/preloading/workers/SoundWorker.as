package com.zutalor.preloading.workers
{
	import com.zutalor.preloading.Asset;
	import com.zutalor.preloading.events.AssetCompleteEvent;
	import com.zutalor.preloading.events.AssetProgressEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
		
	/**
	 *	The SoundWorker class is the worker loads all
	 *	sound files.
	 *	
	 *	<p>This class is not used directly. It is used internally to an
	 *	Asset instance.</p>
	 *	
	 *	<script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	final public class SoundWorker extends Worker
	{
		
		/**
		 * Load an asset of type mp3 or aif.
		 * 
		 * @param asset The Asset instance that needs to be loaded.
		 */
		public override function load(asset:Asset):void
		{
			this.loader = new Sound();
			this.asset = asset;
			this.request = new URLRequest(asset.source);
			//loader.addEventListener(Event.COMPLETE, onComplete,false,0,true);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress,false,0,true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(IOErrorEvent.DISK_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(IOErrorEvent.NETWORK_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(IOErrorEvent.VERIFY_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(Event.OPEN, onOpen,false,0,true);
			start();
		}
		
		override protected function onProgress(pe:ProgressEvent):void
		{
			this.bytesLoaded = pe.bytesLoaded;
			this.bytesTotal = pe.bytesTotal;
			dispatchEvent(new AssetProgressEvent(AssetProgressEvent.PROGRESS, asset));
			if (this.bytesLoaded) // if you want to load the whole file first get rid of this logic block and de-comment the Event.COMPLETE event in load()
			{
				removeEventListeners();
				asset.data = loader;
				dispatchEvent(new AssetCompleteEvent(AssetCompleteEvent.COMPLETE, asset));
				asset = null;
				try { loader.close(); } catch (error:*) { }
			}
		}
		
		override protected function onComplete(e:Event):void
		{
			removeEventListeners();
			asset.data = loader;
			dispatchEvent(new AssetCompleteEvent(AssetCompleteEvent.COMPLETE, asset));
			asset = null;
			try{loader.close();}catch(error:*){}
		}		
	}
}