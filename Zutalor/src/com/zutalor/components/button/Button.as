package com.zutalor.components.button
{
	import com.zutalor.components.base.Component;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.components.label.Label;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.DisplayUtils;
	import com.zutalor.text.StringUtils;
	import com.zutalor.view.properties.ViewItemProperties;
	import flash.display.SimpleButton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Button extends Component implements IComponent
	{
		private var _sb:SimpleButton;
		private var _up:Graphic;
		private var _over:Graphic;
		private var _down:Graphic;
		private var _disabled:Graphic;
		private var _buttonLabels:Array;
		private var _textAttributes:Array
		private var _bp:ButtonProperties;;
		
		protected static var _presets:PropertyManager;
		
		public function Button(name:String)
		{
			super(name);
		}

		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new PropertyManager(ButtonProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var buttonStates:Array;
			var label:Label;

			super.render(viewItemProperties);
			
			_bp = ButtonProperties(_presets.getPropsByName(vip.presetId));
			
			_up = makeButtonState(_bp.upId);
			_over = makeButtonState(_bp.overId);
			_down = makeButtonState(_bp.downId);
			
			if (_bp.disabledId)
				_disabled = makeButtonState(_bp.disabledId);
			else
				_disabled = makeButtonState(_bp.upId);
				
			_sb = new SimpleButton(_up, _over, _down, _up);
			addChild(_sb);
			vip.text = StringUtils.stripLeadingSpaces(vip.text);
			_sb.name = vip.text;				
			vip.hPad = _bp.hPad;
			vip.vPad = _bp.vPad;

			if (!_bp.textAttributesDown)
			{
				_bp.textAttributesDown = _bp.textAttributesDisabled = _bp.textAttributesOver = _bp.textAttributesUp;
			}
			
			_textAttributes = [_bp.textAttributesUp, _bp.textAttributesOver, _bp.textAttributesDown, _bp.textAttributesDisabled];
			buttonStates = [_up, _over, _down, _disabled];
			_buttonLabels = [new Label(name), new Label(name), new Label(name), new Label(name)];
			
			if (!_bp.width) 
			{
				_bp.width = int(vip.width);
				_bp.height = int(vip.height);	
			}
				
			vip.textAttributes = _textAttributes[i];
			vip.width = String(_bp.width);
			vip.height = String(_bp.height);
			vip.align = _bp.align;
			vip.hPad = _bp.hPad;
			vip.vPad = _bp.vPad;
			for (var i:int = 0; i < 4; i++)
			{
				label = _buttonLabels[i];
				label.render(vip);
				buttonStates[i].addChild(label);
				_buttonLabels[i] = label;
				DisplayUtils.alignInRect(label, _bp.width, _bp.height, _bp.align, _bp.hPad, _bp.vPad);
			}
		}
		
		public function set labelText(text:String):void
		{
			var label:Label;
			if (_buttonLabels)
			{
				for (var i:int = 0; i < 4; i++)
				{
					label = _buttonLabels[i];
					label.value = text;
					DisplayUtils.alignInRect(label, _bp.width, _bp.height, _bp.align, _bp.hPad, _bp.vPad);
				}
			}
			name = text;
		}
		
		public function get labelText():String
		{
			if (_buttonLabels)
				return _buttonLabels[0].value;
			else
				return "";
		}
		
		override public function set name(n:String):void
		{
			super.name = n;
			for (var i:int; i < numChildren; i++)
				getChildAt(i).name = n;
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			_sb.enabled = _sb.mouseEnabled = value;
			
			if (!value)
				_sb.upState = _disabled;
			else
				_sb.upState = _up;		
		}
		
		private function makeButtonState(presetId:String):Graphic
		{
			var g:Graphic;
			g = new Graphic(name);
			vip.presetId = presetId;
			g.render(vip)
			return g;
		}
	}
}