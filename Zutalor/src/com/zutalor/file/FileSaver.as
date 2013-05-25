package com.zutalor.file
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class FileSaver extends EventDispatcher
	{
		
		private var urlReq:URLRequest;
		private var urlStream:URLStream;
		private var fileData:ByteArray;
		private var dest:String;
		private var destDir:String;
		
		public static const DESKTOP:String = "desktop";
		public static const APPLICATION:String = "application";
		public static const APP_STORAGE:String = "storage";
		public static const DOCUMENTS:String = "documents";
		public static const USER:String = "user";
		public static const CACHE:String = "cache";
		
		
		public function FileSaver():void
		{
			
		}
		
		public function dispose():void
		{
			removeListeners();
		}
		
		public function write(fileData:ByteArray, dest:String, destDirectory:String = "desktop"):void
		{
			this.dest = dest;
			this.fileData = fileData;
			this.fileData.compress();
			this.destDir = destDirectory;
			writeAirFile();
		}
		
		public function copy(url:String, dest:String, destDirectory:String="desktop"):void
		{
			this.dest = dest;
			this.destDir = destDirectory;
			
			urlReq = new URLRequest(url);
			urlStream= new URLStream();
			fileData = new ByteArray();
			urlStream.addEventListener(Event.COMPLETE, onLoaded, false, 0, true);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			urlStream.load(urlReq);
		}
		
		private function onError(e:IOErrorEvent):void
		{
			removeListeners();
			trace(e);
		}

		private function onLoaded(event:Event):void
		{
			removeListeners();
			urlStream.readBytes(fileData, 0, urlStream.bytesAvailable);
			writeAirFile();
		}

		private function writeAirFile():void
		{

			var file:File;
			var fileStream:FileStream = new FileStream();
			
			switch(destDir)
			{
				case CACHE :
					file = File.cacheDirectory;
					break;
				case APP_STORAGE :
					file = File.applicationStorageDirectory;
					break;
				case DESKTOP :
					file = File.desktopDirectory;
					break;
				case APPLICATION :
					file = File.applicationDirectory;
					break;
				case DOCUMENTS :
					file = File.documentsDirectory;
					break;
				case USER :
					file = File.userDirectory;
					break;
			}
			
			file = file.resolvePath(dest);
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(fileData, 0, fileData.length);
			fileStream.close();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function removeListeners():void
		{
			if (urlStream)
			{
				urlStream.removeEventListener(Event.COMPLETE, onLoaded);
				urlStream.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}		
	}
}