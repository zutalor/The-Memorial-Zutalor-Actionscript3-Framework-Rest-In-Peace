package com.zutalor.components.stepper
{
	import com.zutalor.components.button.Button;
	import com.zutalor.components.Component;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.components.label.Label;
	import com.zutalor.events.UIEvent;
		import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
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
		private var _value:Number;
		private var _displayText:Label;
		private var _sp:StepperProperties;
		private var _background:Graphic;
		
		public var showMs:Boolean;
		
		public static function register(preset:XMLList):void
		{	
			if (!_presets)
				_presets = new PropertyManager(StepperProperties);
			
			_presets.parseXML(preset);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			 var upButton:Button;
			 var downButton:Button;
			 var displayTextWidth:int;
			 var displayTextHeight:int;
			 var sp:StepperProperties;
			
			super.render(viewItemProperties);
			sp = presets.getPropsByName(vip.presetId);
			
			upButton = new Button();
			upButton.vip.presetId = _sp.upButtonId;
			upButton.name = "up";
			upButton.render();
			
			downButton = new Button();
			downButton.vip.presetId = _sp.downButtonId;
			downButton.name = "down";
			downButton.render();
			
			_background = new Graphic();
			_background.vip.presetId = _sp.backgroundId;
			_background.render();
			
			_displayText = new Label();
		
			if (_sp.vertical)
				downButton.y = _background.height - downButton.height;		
			else
				upButton.x = _background.width - upButton.width;
				
			addChild(_background);
			addChild(upButton);
			addChild(downButton);
			addChild(_displayText);
			
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
					_displayText.value = TextUtil.formatTime(_value);
					break;
				default :
					_displayText.value = String(_value);
					break;					
			}	
			
			_displayText.y = ((_background.height - _displayText.height) >> 1)  + 3;
			_displayText.x = (_background.width - _displayText.width) >> 1;
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