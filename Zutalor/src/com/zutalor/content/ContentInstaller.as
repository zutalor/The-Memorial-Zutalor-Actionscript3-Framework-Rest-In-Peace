package com.zutalor.content
{
	import com.zutalor.text.TextUtil;
	import com.zutalor.translate.Translate;
	import com.zutalor.widgets.Dialog;
	
	/**
	 * ...
	 * @author G Pepos
	 */
	public class ContentInstaller
	{
		private var _unpacker:Unpacker;
		private var _onComplete:Function;
		private var _error:Boolean;
		
		public function ContentInstaller(localDir:String)
		{
			_unpacker = new Unpacker(localDir);
		}
		
		public function get error():Boolean
		{
			return _error;
		}
		
		public function install(url:String, onComplete:Function = null):void
		{
			_error = false;
			_onComplete = onComplete;
			_unpacker.unpack(url, onProgress, onDownloadComplete);
		}
		
		// PRIVATE METHODS
		
		private function dispose():void
		{
			_unpacker.dispose();
			_unpacker = null;
		}
		
		private function onProgress(message:String):void
		{
		/*
		   if (message == Unpacker.UNPACK_FILE)
		   Dialog.show(Dialog.NOTIFY, Translate.tText("unpack") + "<br/><br/>" + TextUtil.stripFileExtenstion(_unpacker.currentFile));
		   else
		 Dialog.show(Dialog.NOTIFY, "download", null, _unpacker.percentage);*/
		}
		
		private function onDownloadComplete():void
		{
			/*_error = _unpacker.cancelled;
			if (!_unpacker.cancelled && !_unpacker.error)
				Dialog.show(Dialog.ALERT, "download-success", onDialogComplete);*/
		}
		
		private function onDialogComplete(message:String):void
		{
			if (_onComplete != null)
				_onComplete();
		}
	}
}