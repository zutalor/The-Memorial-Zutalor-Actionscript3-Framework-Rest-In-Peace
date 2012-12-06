package com.zutalor.components.base 
{
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.containers.Container;
	import com.zutalor.containers.base.ViewObject;
	import com.zutalor.events.UIEvent;
	import com.zutalor.utils.Aligner;
	import com.zutalor.view.properties.ViewItemProperties;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Component extends Container implements IComponent
	{
		private var _value:*;
		public var vip:ViewItemProperties;
		protected var aligner:Aligner;

		public function Component(containerName:String)
		{
			super(containerName);
			vip = new ViewItemProperties();
			aligner = new Aligner();
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
			return _value;
		}
		
		public function set value(value:*):void
		{
			_value = value;
			dispatchEvent(new UIEvent(UIEvent.VALUE_CHANGED, null, null, null, value));
		}
		
		public function get isInvisible():Boolean
		{
			return false;
		}
	}
}