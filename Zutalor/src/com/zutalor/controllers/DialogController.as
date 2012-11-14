package com.zutalor.controllers
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.components.Button;
	import com.zutalor.events.UIEvent;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.Translate;
	import com.zutalor.ui.Dialog;
	import flash.desktop.NativeApplication;

	
	public class DialogController extends AbstractUiController
	{	
		private var _vo:Object;
		private var _callBack:Function;
		private var _lastMessage:String;
		
		public function DialogController()
		{
			_vo = new Object();
			_vo.htmlText = "";
		}
		
		override public function getValueObject(params:Object=null):*
		{
			return _vo;
		}
				
		public function setOnSelectionCallback(callback:Function):void
		{
			_callBack = callback;
		}
					
		public function select(choice:String=null):void
		{
			if (_callBack != null)
				_callBack(choice);
		}
		
		public function setMessage(message:String):void
		{	
			_vo.htmlText = Translate.text(message);
			if (_vo.htmlText.toLowerCase().indexOf("<p2>") == -1)
				_vo.htmlText = "<P2>" + _vo.htmlText + " </P2>"
			onModelChange();
		}
		
		public function open(type:String):void
		{
			switch (type)
			{
				case Dialog.NOTIFY :
					initNotify();
					break;
				case Dialog.ALERT :
					initAlert();
					break;
				case Dialog.CONFIRM :
					initConfirm();
					break;
				case Dialog.PROGRESS :
					initProgress();
					break;
				default :
					// ignore
					break;
			}
		}
		
		// PRIVATE METHODS
		
		private function initAlert():void
		{
			var okButton:Button;
			
			okButton = getOkButton();
			vc.setItemVisibility("cancelButton", false);
			vc.setItemVisibility("htmlText", true, .75, .2);
			vc.setItemVisibility("okButton", true, .75, .2);
			
			okButton.x =  (vc.container.width - okButton.width) * .5;
		}
		
		private function initProgress():void
		{
			var cancelButton:Button;

			cancelButton = getCancelButton();
			cancelButton.x = (vc.container.width * .5 - cancelButton.width) * .5;
			
			vc.setItemVisibility("cancelButton", true, .75, .2);
			vc.setItemVisibility("htmlText", true, .75, .2);
			vc.setItemVisibility("okButton", false);
			
		}
		
		private function initNotify():void
		{
			var progressBar:*
			
			vc.setItemVisibility("okButton", false);
			vc.setItemVisibility("cancelButton", false);
			vc.setItemVisibility("background", true, .75, .2);
			vc.setItemVisibility("htmlText", true, .75, .2);
		}
		
		private function close():void
		{
			vc.dispatchUiEvent(UIEvent.CLOSE);
		}
		
		private function initConfirm():void
		{	
			var okButton:Button;
			var cancelButton:Button;
			
			okButton = getOkButton();
			cancelButton = getCancelButton();

			vc.setItemVisibility("htmlText", false);	
			vc.setItemVisibility("okButton", false);
			vc.setItemVisibility("cancelButton", false);
			vc.setItemVisibility("htmlText", true, .75, .2);
			vc.setItemVisibility("cancelButton", true, .75, .2);
			vc.setItemVisibility("okButton", true, .75, .2);
			
			okButton.x = getX(.73, okButton);
			cancelButton.x = getX(.27, cancelButton);
		}	
		
		private function getOkButton():Button
		{
			return vc.getItemByName("okButton");
		}
		
		private function getCancelButton():Button
		{
			return vc.getItemByName("cancelButton");
		}
		
		private function getX(percentage:Number, b:Button):Number
		{
			return (vc.container.width - b.width) * .5;
		}

	}
}