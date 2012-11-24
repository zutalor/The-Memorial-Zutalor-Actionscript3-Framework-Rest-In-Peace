package com.zutalor.components
{
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.StepperProperties;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.text.TextAttributes;
	import com.zutalor.text.TextUtil;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Stepper extends Component implements IComponent
	{
		private var _valueDisplay:Sprite;
		private var _value:Number;
		private var _displayText:TextField;
		private var _sp:StepperProperties;
		private var _background:Graphic;
		
		public var showMs:Boolean;
		
		public static function register(preset:XMLList):void
		{	
			if (!_presets)
				_presets = new PropertyManager(StepperProperties);
			
			_presets.parseXML(preset);
		}
		
		override public function render(vip:ViewItemProperties):void
		{
			 var upButton:Button;
			 var downButton:Button;
			 var displayTextWidth:int;
			 var displayTextHeight:int;
			 var sp:StepperProperties;
			
			sp = presets.getPropsByName(vip.presetId);
			
			upButton = new Button(_sp.upButtonId);
			upButton.name = "up";
			downButton = new Button(_sp.downButtonId);
			downButton.name = "down";
			_background = new Graphic();
			_background.render(_sp.backgroundGraphicId);
			
			_displayText = new TextField();
			_valueDisplay = new Sprite();
			
			if (_sp.vertical)
				downButton.y = _background.height - downButton.height;		
			else
				upButton.x = _background.width - upButton.width;
				
			addChild(_background);
			addChild(upButton);
			addChild(downButton);
			addChild(_valueDisplay);
			
			displayTextWidth = _background.width - downButton.width - upButton.width;
			displayTextHeight = _background.height - downButton.height - upButton.height;
			
			_value = _sp.initialValue;
			setDisplayText();
				
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);			
		}
		
		override public function dispose():void
		{
			//TODO
		}
		
		override public function get value():*
		{
			return _value;
		}
		
		override public function set value(v:*):void
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
					TextAttributes.apply(_displayText, _sp.textAttributes);
					_valueDisplay.addChild(_displayText);
					break;
				default :
					_displayText.text = String(_value);
					TextAttributes.apply(_displayText, _sp.textAttributes);
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