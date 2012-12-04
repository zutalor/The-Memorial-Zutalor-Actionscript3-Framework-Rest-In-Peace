package com.zutalor.components.button
{
	import com.zutalor.components.Component;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.components.label.Label;
		import com.zutalor.utils.DisplayUtils;
		import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
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

		public static function register(xml:XMLList):void
		{
			if (!_presets)
				_presets = new PropertyManager(ButtonProperties);
			
			_presets.parseXML(xml);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var width:Number;
			var height:Number;
			var buttonStates:Array;
			
			super.render(viewItemProperties);
			
			_bp = ButtonProperties(_presets.getPropsByName(vip.presetId));
			
			_up = new Graphic(name);
			this.vip.presetId = _bp.upId;
			_up.render(vip);
	
			_over = new Graphic(name);
			vip.presetId = _bp.overId;
			_over.render(vip);

			_down = new Graphic(name);
			vip.presetId = _bp.downId;
			_down.render(vip);

			_disabled = new Graphic(name);
			
			if (_bp.disabledId)
				vip.presetId = _bp.disabledId;
			else
				vip.presetId = _bp.upId;
			
			_disabled.render(vip);	
				
			_sb = new SimpleButton(_up, _over, _down, _up);
			addChild(_sb);
			_sb.name = vip.text;				
			
			if (!_bp.width) 
			{
				width = _up.width;
				height = _up.height;	
			}
			else
			{
				width = _bp.width;
				height = _bp.height;
			}
			
			vip.hPad = _bp.hPad;
			vip.vPad = _bp.vPad;

			if (!_bp.textAttributesDown)
			{
				_bp.textAttributesDown = _bp.textAttributesDisabled = _bp.textAttributes;
			}
			
			_textAttributes = [_bp.textAttributes, _bp.textAttributes, _bp.textAttributesDown, _bp.textAttributesDisabled];

			buttonStates = [_up, _over, _down, _disabled];
			_buttonLabels = [new Label(name), new Label(name), new Label(name), new Label(name)];
			
			var label:Label;
			for (var i:int = 0; i < 4; i++)
			{
				label = _buttonLabels[i];
				vip.textAttributes = _textAttributes[i];
				vip.align = _bp.align;
				vip.hPad = _bp.hPad;
				vip.vPad = _bp.vPad;
				label.render(vip);
				buttonStates[i].addChild(label);
				_buttonLabels[i] = label;
				DisplayUtils.alignInRect(label, buttonStates[0].width, buttonStates[0].height, 
																		_bp.align, _bp.hPad, _bp.vPad);
			}
		}
		
		public function set labelText(text:String):void
		{
			var label:Label;
			if (_buttonLabels)
				for (var i:int = 0; i < 4; i++)
				{
					label = _buttonLabels[i];
					label.value = text;
					DisplayUtils.alignInRect(label, int(vip.height), int(vip.width),
															_bp.align, _bp.hPad, _bp.vPad);
				}
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
	}
}