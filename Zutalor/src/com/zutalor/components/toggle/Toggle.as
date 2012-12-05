package com.zutalor.components.toggle
{
	import com.zutalor.components.base.Component;
	import com.zutalor.components.button.Button;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.view.properties.ViewItemProperties;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Toggle extends Component implements IComponent
	{
		private var _onState:Button;
		private var _offState:Button;
		private var _name:String
		
		protected static var _presets:PropertyManager;
				
		public function Toggle(name:String)
		{
			super(name);
		}
		
		public static function registerPresets(options:Object):void
		{	
			if (!_presets)
				_presets = new PropertyManager(ToggleProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var tp:ToggleProperties;
			var vp:ViewItemProperties;
			
			super.render(viewItemProperties);
			
			tp = _presets.getPropsByName(vip.presetId);
			vp = new ViewItemProperties();
			vp.presetId = tp.onStateButtonId;
			vp.text = vip.text;
			
			_onState = new Button(vip.name);
			_onState.render(vp);
			
			vp.presetId = tp.offStateButtonId;
			_offState = new Button(vip.name);
			_offState.render(vp);
			
			value = tp.initialValue;
			addChild(_onState);
			addChild(_offState);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
		
		private function onMouseDown(me:MouseEvent):void
		{
			if (value)
				value = false;
			else
				value = true;
			
			toggle();					
		}
		
		override public function set value(value:*):void
		{
			super.value = value;
			toggle();	
		}
		
		private function toggle():void
		{
			if (value) 
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