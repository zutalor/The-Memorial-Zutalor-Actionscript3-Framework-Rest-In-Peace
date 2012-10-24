package com.zutalor.content 
{
	/**
	 * ...
	 * @author G Pepos
	 */

	import com.zutalor.ui.Dialog;
	import com.zutalor.utils.MasterClock;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.system.Capabilities;
	import nochump.util.zip.*;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.net.URLLoader;
 
	public class Unpacker
	{
		public static const UNPACK_FILE:String = "unpack";	
		public static const DOWNLOADING_FILE:String = "downloading";	
		
		private var _slash:String;
		private var _directory:String;
		private var _currentFile:String;
		private var _percentage:Number;
		private var _stream:URLStream;
		private var _zipFile:ZipFile;
		private var _cancelled:Boolean;
		private var _error:Boolean;
		private var _progressCallback:Function;
		private var _completeCallback:Function;
 
		public function get percentage():Number  { return _percentage; }
		public function get directory():String   { return _directory; }
		public function get currentFile():String { return _currentFile; }
		public function get cancelled():Boolean { return _cancelled; }
		public function get error():Boolean { return _error; }
		
		public function unpack(url:String, progressCallback:Function = null, completeCallback:Function = null):void
		{
			_cancelled = false;
			_error = false;
			_progressCallback = progressCallback;
			_completeCallback = completeCallback;
			if (url.indexOf('http://') < 0) 
					url = 'http://' + url;
					
			_stream = new URLStream();
			_stream.load(new URLRequest(url));
			_stream.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_stream.addEventListener(Event.COMPLETE, extract);
		}
		
		public function Unpacker(dir:String):void
		{
			_directory = dir; 
			_percentage = 0;
			
			if (Capabilities.os.toLowerCase().indexOf("win") != -1)
				_slash = "\\";
			else
				_slash = "/";
			
			if ((_directory != "") &&
					(_directory.charAt(_directory.length - 1) != _slash))
			{
				_directory += _slash;
			}
		}
	 
		public function cancel():void
		{
			_cancelled = true;
		}
		
		public function dispose():void
		{
			removeEventListeners();
		}
		
		// PRIVATE METHODS
		
		private function removeEventListeners():void
		{
			_stream.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			_stream.removeEventListener(Event.COMPLETE, extract);
		}
		 
		private function onDownloadProgress(e:ProgressEvent):void
		{
			 _percentage = Number(e.bytesLoaded / e.bytesTotal);
			 if (_progressCallback != null)
				_progressCallback(DOWNLOADING_FILE);	
		}
		
		private function onWriteProgress(e:OutputProgressEvent):void
		{
			 _percentage = Number(e.bytesPending / e.bytesTotal);
			 if (_progressCallback != null)
				_progressCallback(UNPACK_FILE);
		}
		
		private function onIOError(e:IOErrorEvent):void
		{
			_error = true;
			//TODO Clean UP
			Dialog.show(Dialog.ALERT, Dialog.IO_ERROR, finishUp);

		}
		
		private function onDiskError(e:IOErrorEvent):void
		{
			_error = true;
			// TODO Clean UP
			Dialog.show(Dialog.ALERT, Dialog.DISK_ERROR, finishUp);
		}
		 
		private function extract(e:Event):void
		{
			removeEventListeners();
			_zipFile = new ZipFile(_stream);
			if (!_zipFile)
			{
				Dialog.show(Dialog.ALERT, Dialog.DISK_ERROR, finishUp);
				error = true;
			}
			else
				extractFile(0);
		}
		
		private function extractFile(id:int):void
		{
			var filePath:String;
			var zipEntry:ZipEntry;
							
			zipEntry = ZipEntry(_zipFile.entries[id]);
			filePath = _directory + zipEntry.name;			
			_currentFile = zipEntry.name;
			 
			var storage:File = new File(filePath);
			if (zipEntry.name.charAt(zipEntry.name.length - 1) == _slash)
				storage.createDirectory();
			else
			{
				var entry:FileStream = new FileStream();
	
				entry.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onWriteProgress, false, 0, true);
				entry.addEventListener(Event.CLOSE, onClose, false, 0, true);
				entry.addEventListener(IOErrorEvent.DISK_ERROR, onDiskError, false, 0, true);
				
				entry.openAsync(storage, FileMode.WRITE);
				if (_progressCallback != null)
					_progressCallback(UNPACK_FILE);
				
				entry.writeBytes(_zipFile.getInput(zipEntry));
				entry.close(); //this is okay here as it doesn't really close but primes entry to dispacth a close event.
			}
			
			function onClose(e:Event):void
			{
				entry.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onWriteProgress);
				entry.removeEventListener(Event.CLOSE, onClose);
				
				if (id < _zipFile.entries.length - 1 && !_cancelled && !_error) 
					extractFile(id + 1);
				else
				{
					if (_cancelled)
					{
						// TODO Clean Up
						finishUp();
					}
					else
						finishUp();
				}
			}
		}
		
		private function finishUp(message:String = null):void
		{
			if (_completeCallback != null)
				_completeCallback();
			
		}
	}
}