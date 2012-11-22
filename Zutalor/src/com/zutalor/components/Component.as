package com.zutalor.components 
{
	import com.zutalor.containers.Container;
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.propertyManagers.PropertyManager;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Component extends Container implements IComponent
	{
		private var _enabled:Boolean;
		protected static var presets:PropertyManager;
		
		public function Component(id:String, data:String)
		{
			
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
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
	}
}