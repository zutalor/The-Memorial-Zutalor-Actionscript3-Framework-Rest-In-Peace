package com.zutalor.components.base
{
	import com.zutalor.containers.Container;
	import com.zutalor.events.UIEvent;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.view.properties.ViewItemProperties;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Component extends Container implements IComponent
	{
		private var _value:*;
		public var vip:ViewItemProperties;

		public function Component(containerName:String)
		{
			super(containerName);
			vip = new ViewItemProperties();
		}
		
		public function render(viewItemProperties:ViewItemProperties = null):void
		{
			if (viewItemProperties)
				vip = viewItemProperties;
		}
				
		public function onValueChange(uie:UIEvent):void
		{
			value = uie.value;
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