package com.zutalor.components 
{
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.containers.ViewObject;
	import com.zutalor.events.UIEvent;
	import com.zutalor.view.properties.ViewItemProperties;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Component extends ViewObject implements IComponent
	{
		private var _value:*;
		public var vip:ViewItemProperties = new ViewItemProperties();
		
		public function render(viewItemProperties:ViewItemProperties = null):void
		{
			if (viewItemProperties)
				vip = viewItemProperties;
		}
				
		public function onValueChange(uie:UIEvent):void
		{
			
		}
		
		public function dispatchValueChange(uie:UIEvent):void
		{
			dispatchEvent(uie.clone());
		}
		
		public function get value():*
		{
			return _value;
		}
		
		public function set value(value:*):void
		{
			_value = value;
			dispatchEvent(new UIEvent(UIEvent.VALUE_CHANGED, null, null, null, value));
		}
	}
}