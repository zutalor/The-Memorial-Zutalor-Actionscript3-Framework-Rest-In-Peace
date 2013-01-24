package com.zutalor.content 
{
	/**
	 * ...
	 * @author G Pepos
	 */


	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import nochump.util.zip.*;
 
	public class Unpacker
	{
		public static const UNPACK_FILE:String = "unpack";	
		public static const DOWNLOADING_FILE:String = "downloading";	
		
		private var _slash:String;
		private var _directory:String;
		private var _currentFile:String;
		private var _percentage:Number;
		private var _cancelled:Boolean;
		private var _error:Boolean;
		private var _progressCallback:Function;
		private var _completeCallback:Function;
		private var _url:String;
 
		public function get percentage():Number  { return _percentage; }
		public function get directory():String   { return _directory; }
		public function get currentFile():String { return _currentFile; }
		public function get cancelled():Boolean { return _cancelled; }
		public function get error():Boolean { return _error; }
		
		public function Unpacker(dir:String)
		{
			_directory = dir; 
			_percentage = 0;
			
			//_fzip = new FZip();
			
			
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
		
		public function unpack(url:String, progressCallback:Function = null, completeCallback:Function = null):void
		{
			
			_cancelled = false;
			_error = false;
			
			_url = url;
			_progressCallback = progressCallback;
			_completeCallback = completeCallback;
			
			if (url.indexOf('http://') < 0) 
				url = 'http://' + url;
		
			addEventListeners();
			_fzip.load(new URLRequest(url));
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
		
		private function addEventListeners():void
		{
			_fzip.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			_fzip.addEventListener(Event.COMPLETE, extractFile);
			_fzip.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_fzip.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onIOError);
		}
		
		private function removeEventListeners():void
		{
			_fzip.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			_fzip.removeEventListener(Event.COMPLETE, extractFile);
			_fzip.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_fzip.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onIOError);
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
		
		private function onIOError(e:IOErrorEvent = null):void
		{
			
			//TODO Clean UP
			//Dialog.show(//Dialog.CONFIRM, //Dialog.IO_ERROR, onConfirm);
			
			function onConfirm(m:String):void
			{
/*				if (m == //Dialog.OK)
					unpack(_url, _progressCallback, _completeCallback);
				else
				{
					_error = true;
					finishUp();
				}
*/			}
		}
		
		private function onDiskError(e:IOErrorEvent):void
		{
			_error = true;
			// TODO Clean UP
			//Dialog.show(//Dialog.ALERT, //Dialog.DISK_ERROR, finishUp);
		}
		
		private function extractFile(id:int = 0):void
		{
			var filePath:String;
			var zipEntry:FZipFile;
			
			zipEntry = _fzip.getFileAt(id);
			
			if (!zipEntry)
				onIOError();
			else
			{
				filePath = _directory + zipEntry.filename;			
				_currentFile = zipEntry.filename;
				 
				var storage:File = new File(filePath);
				if (zipEntry.filename.charAt(zipEntry.filename.length - 1) == _slash)
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
					
					entry.writeBytes(zipEntry.content);
					entry.close(); //this is okay here as it doesn't really close but primes entry to dispacth a close event.
				}
			}
			
			function onClose(e:Event):void
			{
				entry.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onWriteProgress);
				entry.removeEventListener(Event.CLOSE, onClose);
				
				if (id < _fzip.getFileCount() - 1 && !_cancelled && !_error) 
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