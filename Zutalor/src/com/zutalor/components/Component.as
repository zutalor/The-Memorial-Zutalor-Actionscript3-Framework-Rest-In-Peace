package com.zutalor.components 
{
	import com.zutalor.containers.ViewObject;
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.propertyManagers.PropertyManager;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Component extends ViewObject
	{
		
		protected static var _presets:PropertyManager;
		
		public static function get presets():PropertyManager
		{
			return _presets;
		}
		
		override public function set name(n:String):void
		{
			for (var i:int; i < numChildren; i++)
				getChildAt(i).name = n;
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