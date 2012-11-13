package com.zutalor.components
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.StepperProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.TextUtil;
	import com.zutalor.ui.DisposableSprite;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Stepper extends DisposableSprite implements IDisposable
	{
		
		private var _upButton:Button;
		private var _downButton:Button;
		private var _displayTextWidth:int;
		private var _displayTextHeight:int;
		private var _background:Graphic;
		private var _sp:StepperProperties;
		private var _valueDisplay:Sprite;

		public var _value:Number;
		public var _displayText:TextField;
		
		public var showMs:Boolean;
		
		public function create(stepperId:String):void
		{
			_sp = Props.pr.stepperPresets.getPropsByName(stepperId);
			
			_upButton = new Button(_sp.upButtonId);
			_upButton.name = "up";
			_downButton = new Button(_sp.downButtonId);
			_downButton.name = "down";
			_background = new Graphic();
			_background.render(_sp.backgroundGraphicId);
			_displayText = new TextField();
			_valueDisplay = new Sprite();
			
			if (_sp.vertical)
				_downButton.y = _background.height - _downButton.height;		
			else
				_upButton.x = _background.width - _upButton.width;
				
			addChild(_background);
			addChild(_upButton);
			addChild(_downButton);
			addChild(_valueDisplay);
			
			_displayTextWidth = _background.width - _downButton.width - _upButton.width;
			_displayTextHeight = _background.height - _downButton.height - _upButton.height;
			
			_value = _sp.initialValue;
			setDisplayText();
				
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);			
		}
		
		override public function dispose():void
		{
			//TODO
		}
		
		public function get value():Number
		{
			return _value;
		}
		
		public function set value(v:Number):void
		{
			_value = v;
			setDisplayText();
		}
		
		protected function setDisplayText():void
		{
			switch (_sp.type)
			{
				case "float" :
				case "currency" :
					// TODO
					break;
				case "time" :
					_displayText.text = TextUtil.formatTime(_value);
					TextUtil.applyTextAttributes(_displayText, _sp.textAttributes);
					_valueDisplay.addChild(_displayText);
					break;
				default :
					_displayText.text = String(_value);
					TextUtil.applyTextAttributes(_displayText, _sp.textAttributes);
					_valueDisplay.addChild(_displayText);
					break;					
			}	
			
			_valueDisplay.y = (_background.height >> 1) - (_valueDisplay.height >> 1) + 3;
			_valueDisplay.x = (_background.width >> 1) - (_valueDisplay.width >> 1);
		}
						
		private function onMouseDown(me:MouseEvent):void
		{
			if (me.target.name == "up")
			{
				if (_value < _sp.maxValue)
					_value += _sp.increment;
					
				if (_value > _sp.maxValue)
					_value = _sp.maxValue;
			}
			else if (me.target.name == "down")
			{
				if (_value > _sp.minValue)
					_value -= _sp.increment;
				
				if (_value < _sp.minValue)
					_value = _sp.minValue;
			}		
			setDisplayText();
			dispatchEvent(new UIEvent(UIEvent.VALUE_CHANGED, null, null, null, _value));
		}
		
		private function formatTime():String
		{
			var hours:int;
			var minutes:int;
			var seconds:int;
			var ms:int;
			var time:String;
			
			var date:Date = new Date(null, null, null, 0, 0, int(_value));
			time = "";
			hours = date.getHours();
			minutes = date.getMinutes();
			seconds = date.getSeconds();
			ms = date.getMilliseconds();
			
			if (hours)
			{
				time = String(hours);		
				time += ":";
			}
			
			if (minutes)
				time += minutes;
			else
				time += "00";
			
			time += ":";
			
			if (!seconds)
				time += "00"
			else if (seconds < 10)
				time += "0" + seconds;
			else
				time += seconds;
				
			if (showMs)
			{
				time += ":";
				if (ms < 10)
					time += "0" + ms;
				else
					time += ms;
			}
			
			return(time);
		}		
	}
}