package com.zutalor.components 
{
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.containers.ViewObject;
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.view.properties.ViewItemProperties;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Component extends ViewObject implements IComponent
	{
		
		protected static var _presets:PropertyManager;
		public var vip:ViewItemProperties = new ViewItemProperties();
		
		public static function get presets():PropertyManager
		{
			return _presets;
		}
		
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
			return null;
		}
		
		public function set value(value:*):void
		{
			
		}
	}
}