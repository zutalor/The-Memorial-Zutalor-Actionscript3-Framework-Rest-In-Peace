package com.zutalor.components
{
	import com.zutalor.containers.Container;
	import com.zutalor.events.UIEvent;
	import com.zutalor.interfaces.IViewItem;
	import com.zutalor.properties.ToggleProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Toggle extends Component implements IViewItem
	{
		private var _onState:Button;
		private var _offState:Button;
		private var _value:Boolean;
		private var _name:String
		
		public function Toggle(toggleId:String, text:String)
		{
			init(toggleId, text);
		}
		
		public static function register(preset:XMLList):void
		{
			if (!presets)
				presets = new PropertyManager(ToggleProperties);
			
			presets.parseXML(preset);
		}
		
		private function init(toggleId:String, text:String):void
		{
			var tp:ToggleProperties = presets.getPropsByName(toggleId);
			
			_onState = new Button(tp.onStateButtonId, text);
			_offState = new Button(tp.offStateButtonId, text);
			
			value = tp.initialValue;
			addChild(_onState);
			addChild(_offState);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
		
		private function onMouseDown(me:MouseEvent):void
		{
			if (_value)
				_value = false;
			else
				_value = true;
			
			toggle();
			dispatchEvent(new UIEvent(UIEvent.VALUE_CHANGED, null, null, null, _value));						
		}
		
		override public function set value(value:*):void
		{
			_value = value;
			toggle();	
		}
		
		private function toggle():void
		{
			if (_value) 
			{
				_onState.visible = true;
				_offState.visible = false;
			}
			else
			{
				_onState.visible = false;
				_offState.visible = true;
			}
		}				
		
		override public function get value():*
		{
			return _value;
		}

		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;			
			_onState.enabled = _offState.enabled = value;
		}
		
		override public function dispose():void
		{
			removeChildAt(0);
			removeChildAt(0);
			_onState = null;
			_offState = null;
		}
	}
}