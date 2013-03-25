package com.zutalor.file
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class FileLoader extends EventDispatcher
	{
		public var data:*;
		public var charSet:String = "utf-8";
		private var file:File;
		
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
	}
	
/*	ar file:File = File.desktopDirectory.resolvePath("MyTextFile.txt");
var stream:FileStream = new FileStream();
stream.open(file, FileMode.WRITE);
stream.writeUTFBytes("This is my text file.");
stream.close();*/
}