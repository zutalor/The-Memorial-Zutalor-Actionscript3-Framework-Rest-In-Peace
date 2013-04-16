package com.zutalor.file
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class FileLoader extends EventDispatcher
	{
		public var data:*;
		private var file:FileReference;
		private var charSet:String;
		
		public function FileLoader()
		{
			
		}
		
		public function selectFile(fileType:String="Select", mask:String = "*.*", charSet:String = "utf-8"):void
		{
			this.charSet = charSet;
			file = new FileReference();
			file.addEventListener( Event.SELECT, onFileSelect, false, 0, true );
			file.addEventListener( Event, onLoadComplete, false, 0, true );
			file.browse( [new FileFilter( fileType, mask )] );
		}
		
		private function onFileSelect( event:Event ):void
		{
			file.load();
		}

		private function onLoadComplete( event:Event ):void
		{
			data = file.data.readMultiByte( file.data.bytesAvailable, charSet );
			//trace(data);
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
	
/*	ar file:File = File.desktopDirectory.resolvePath("MyTextFile.txt");
var stream:FileStream = new FileStream();
stream.open(file, FileMode.WRITE);
stream.writeUTFBytes("This is my text file.");
stream.close();*/
}