package com.zutalor.file
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class FileLoader extends EventDispatcher
	{
		public var data:*;
		public var charSet:String = "utf-8";
		private var file:File;
		public var error:Error;
		
		public function FileLoader()
		{
			
		}
		
		public function selectFile(title:String="Select", fileFilter:String = "*.*"):void
		{
			file = File.desktopDirectory;
			file.addEventListener( Event.SELECT, onFileSelect, false, 0, true );
			file.browseForOpen(title, [new FileFilter( title, fileFilter )] );
		}
		
		private function onFileSelect( event:Event ):void
		{
			file.addEventListener( Event.COMPLETE, onLoadComplete, false, 0, true );
			file.load();
		}

		private function onLoadComplete( event:Event ):void
		{
			data = file.data.readMultiByte( file.data.bytesAvailable, charSet);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function load(vo:*, populateVO:Function, fileName:String,  
										onComplete:Function = null):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath(fileName);
			var length:Number;
			var ba:ByteArray;

			error = null;
			file.addEventListener(Event.COMPLETE, onLoaded, false, 0, true);
			file.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true );			
			file.load();
			
			function onLoaded(e:Event):void
			{
				file.removeEventListener(Event.COMPLETE, onLoaded);
				file.removeEventListener(IOErrorEvent.IO_ERROR, onError);				
				try {
					ba = file.data;
					ba.uncompress();
					populateVO(ba, vo);

					
				} catch (e:Error) { error = e; }
				
				if (onComplete != null)
						onComplete();
			}
			
			function onError(e:Event):void
			{
				file.removeEventListener(Event.COMPLETE, onLoaded);
				file.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				error = new Error(IOErrorEvent.IO_ERROR);
				if (onComplete != null)
					onComplete();
			}
		}		
	}
	
/*	ar file:File = File.desktopDirectory.resolvePath("MyTextFile.txt");
var stream:FileStream = new FileStream();
stream.open(file, FileMode.WRITE);
stream.writeUTFBytes("This is my text file.");
stream.close();*/
}