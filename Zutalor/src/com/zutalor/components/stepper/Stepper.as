package com.zutalor.components.stepper
{
	import com.zutalor.components.button.Button;
	import com.zutalor.components.base.Component;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.components.label.Label;
	import com.zutalor.events.UIEvent;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.properties.PropertyManager;
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
		private var _displayText:Label;
		private var _sp:StepperProperties;
		private var _background:Graphic;
		
		public var showMs:Boolean;
		
		protected static var _presets:PropertyManager;
		
		public function Stepper(name:String)
		{
			super(name);
		}
		
		public static function registerPresets(options:Object):void
		{	
			if (!_presets)
				_presets = new PropertyManager(StepperProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			 var upButton:Button;
			 var downButton:Button;
			 var displayTextWidth:int;
			 var displayTextHeight:int;
			 var sp:StepperProperties;
			
			super.render(viewItemProperties);
			sp = _presets.getPropsByName(vip.presetId);
			
			upButton = new Button(vip.name);
			upButton.vip.presetId = _sp.upButtonId;
			upButton.name = "up";
			upButton.render();
			
			downButton = new Button(vip.name);
			downButton.vip.presetId = _sp.downButtonId;
			downButton.name = "down";
			downButton.render();
			
			_background = new Graphic(vip.name);
			_background.vip.presetId = _sp.backgroundId;
			_background.render();
			
			_displayText = new Label(vip.name);
		
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
			
			value = _sp.initialValue;
			value = 
			setDisplayText();
				
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);			
		}
		
		override public function dispose():void
		{
			//TODO
		}
		
		override public function get value():*
		{
			return value;
		}
		
		override public function set value(v:*):void
		{
			super.value = v;
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
					_displayText.value = TextUtil.formatTime(value);
					break;
				default :
					_displayText.value = String(value);
					break;					
			}	
			
			_displayText.y = ((_background.height - _displayText.height) >> 1)  + 3;
			_displayText.x = (_background.width - _displayText.width) >> 1;
		}
						
		private function onMouseDown(me:MouseEvent):void
		{
			if (me.target.name == "up")
			{
				if (value < _sp.maxValue)
					value += _sp.increment;
					
				if (value > _sp.maxValue)
					value = _sp.maxValue;
			}
			else if (me.target.name == "down")
			{
				if (value > _sp.minValue)
					value -= _sp.increment;
				
				if (value < _sp.minValue)
					value = _sp.minValue;
			}		
			setDisplayText();
		}
		
		private function formatTime():String
		{
			var hours:int;
			var minutes:int;
			var seconds:int;
			var ms:int;
			var time:String;
			
			var date:Date = new Date(null, null, null, 0, 0, int(value));
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