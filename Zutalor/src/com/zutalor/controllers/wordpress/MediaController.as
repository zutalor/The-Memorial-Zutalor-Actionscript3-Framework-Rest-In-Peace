package com.zutalor.controllers.wordpress
{
	import com.zutalor.amfphp.Remoting;
	import com.zutalor.controllers.base.UiControllerBase;
	import com.zutalor.interfaces.IUiController;
	import flashpress.vo.WpAttachmentVO;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MediaController extends UiControllerBase implements IUiController
	{
		private var _attachments:*;
		private var _numAttachments:int;
		private var _curAttachment:int;
		private var _wpAttachmentVO:WpAttachmentVO;
		
		private var remoting:Remoting;
		
		public function MediaController()
		{
		}
				
		override public function getValueObject(params:Object=null):*
		{
			if (_attachments)
				return _attachments[_curAttachment];
			else
				return null;
		}
				
		public function read(args:String=null):void
		{
			remoting = new Remoting();
			remoting.call("WpMethodsService.getMedia", "flashpress.vo.WpAttachmentVO", WpAttachmentVO, onModelChange, onModelError, "image", "-1");
		}
		
		override public function onModelChange(pVO:* = null):void
		{
			_attachments = pVO;
			_numAttachments = _attachments.length;
			_curAttachment = 0;
			remoting = null;
			super.onModelChange(pVO);
		}
		
		public function first(args:String=null):void
		{
			if (!_attachments)
				read();
			_curAttachment = 0;	
		}
		
		public function last(args:String=null):void
		{
			if (!_attachments)
				read();
			
			_curAttachment = _numAttachments - 1;
			
		}
		
		public function next(args:String=null):void
		{
			if (!_attachments)
				first();
			else if (_curAttachment < _numAttachments -1)
				_curAttachment++;
		}
		
		public function previous(args:String=null):void
		{
			if (!_attachments)
				first();
			else if (_curAttachment > 0)
				_curAttachment--;
		}
	}
}