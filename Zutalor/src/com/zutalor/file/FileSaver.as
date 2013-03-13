package com.zutalor.file 
{
	import flash.events.Event;
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
	public class FileSaver 
	{
		
		public function FileSaver() 
		{
			
		}
		
		public function withDialog(url:String, dest:String):void
		{
			var request:URLRequest = new URLRequest(url);
			var fileRef:FileReference = new FileReference();
			fileRef.download(request, dest);
		}
		
		public function withoutDialog(url:String, dest:String):void
		{
		
			var urlReq:URLRequest = new URLRequest(url);
			var urlStream:URLStream = new URLStream();
			var fileData:ByteArray = new ByteArray();
			urlStream.addEventListener(Event.COMPLETE, loaded, false, 0, true);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			
			urlStream.load(urlReq);

			function onError(e:IOErrorEvent):void
			{
				trace(e);
			}

			function loaded(event:Event):void
			{
				urlStream.removeEventListener(Event.COMPLETE, loaded);
				urlStream.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				urlStream.readBytes(fileData, 0, urlStream.bytesAvailable);
				writeAirFile();
			}

			function writeAirFile():void
			{ 
				// Change the folder path to whatever you want plus name your mp3
				// If the folder or folders does not exist it will create it.
				var file:File = File.userDirectory.resolvePath(dest);
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(fileData, 0, fileData.length);
				fileStream.close();
				trace("The file is written.");
			}
		}
	}
}