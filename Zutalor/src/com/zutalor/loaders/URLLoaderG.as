package com.zutalor.loaders
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class URLLoaderG extends EventDispatcher
	{
		private var _loader:URLLoader;
		private var _data:*;
		private var _url:String;
		private var _callback:Function;
		private var _error:Boolean;
		
		public function load(url:String, callBack:Function, dataFormat:String = URLLoaderDataFormat.TEXT):void
		{
			_callback = callBack;
			_url = url;
			_loader = new URLLoader();
			_error = false;
			_loader.dataFormat=dataFormat;
			_loader.addEventListener(Event.COMPLETE,onLoadComplete);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,onHttpStatus);
			_loader.addEventListener(IOErrorEvent.DISK_ERROR,errorExit);
			_loader.addEventListener(IOErrorEvent.IO_ERROR,errorExit);
			_loader.addEventListener(IOErrorEvent.NETWORK_ERROR,errorExit);
			_loader.addEventListener(IOErrorEvent.VERIFY_ERROR, errorExit);
			_loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.load(new URLRequest(url));
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			dispatchEvent(e);
		}
		
		public function dispose():void
		{
			removeListeners();
			_loader = null;
			_data = null;
			_error = false;
		}
		
		public function get url():String 
		{
			return _url;
		}
		
		public function get data():*
		{
			return _data;
		}
			
		public function get error():Boolean
		{
			return _error;
		}
		
		private function onLoadComplete(e:Event):void
		{
			e.target.close();
			removeListeners();
			_data = e.target.data;
			_callback(this);
		}
		
		private function errorExit(e:Event):void
		{
			_error = true;
			_callback(this);
		}		
		
		private function onHttpStatus(e:HTTPStatusEvent):void
		{
			if(e.status != 0 && e.status != 200)
			{
				_error = true;
				errorExit(e);
				trace("WARNING:  file was not loaded, there was status error: "+e.toString());
			}
		}

		private function removeListeners():void
		{
			_loader.removeEventListener(Event.COMPLETE,onLoadComplete);
			_loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS,onHttpStatus);
			_loader.removeEventListener(IOErrorEvent.DISK_ERROR,errorExit);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR,errorExit);
			_loader.removeEventListener(IOErrorEvent.NETWORK_ERROR,errorExit);
			_loader.removeEventListener(IOErrorEvent.VERIFY_ERROR, errorExit);
			_loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
		}
	}	
}