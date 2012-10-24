package {
	import be.nascom.flash.display.keyboard.touchscreen.Keyboard;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class TouchScreenKeyboard extends Sprite
	{
		private var _xmlDoc:XML;
		private var _textField:TextField;
		private var _keyboardTouch:Keyboard;
		
		public function TouchScreenKeyboard()
		{
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.x = 100;
			this.y = 100;
			
			this.loadXML();
		}
		private function init():void
		{
			this.createTextField();
			this.createKeyboardTouch();
			
			this._keyboardTouch.setSymbol("backspace", new BackspaceSymbol());
		}
		
		private function createKeyboardTouch():void
		{
			var fmtChar:TextFormat = new TextFormat("Arial", 14, 0x000000);
			var fmtShift:TextFormat = new TextFormat("Arial", 10, 0x666666);
			
			this._keyboardTouch = new Keyboard(this._xmlDoc, fmtChar, fmtShift);
			this._keyboardTouch.inputField = this._textField;
			this._keyboardTouch.y = 100;
			this.addChild(this._keyboardTouch);
		}
		private function createTextField():void
		{
			var fmt:TextFormat = new TextFormat("Arial", 30);
			
			this._textField = new TextField();
			this._textField.background = true;
			this._textField.type = TextFieldType.INPUT;
			this._textField.defaultTextFormat = fmt;
			this._textField.width = 500;
			this._textField.height = 45;
			this.addChild(this._textField);
		}
		
		private function loadXML():void
		{
			var request:URLRequest;
			var urlLoader:URLLoader;
			
			request = new URLRequest("assets/xml/keyboard_basic.xml");
			urlLoader = new URLLoader(request);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.load(request);
		}
		private function onComplete(e:Event):void
		{
			this._xmlDoc = new XML(e.target.data);
			this.init();
		}
	}
}
