package com.zutalor.components.text 
{
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.properties.ViewItemProperties;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Text extends Component implements IComponent 
	{		
		public var textField:TextField;
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super.render(viewItemProperties);
			editable = true;
			textField = new TextField();
			if (vip.text)
			{
				textField.text = vip.text;
				applyTextAttributes();
			}
			addChild(textField);
		}
		
		override public function set width(w:Number):void
		{
			textField.width = w;
		}
		
		override public function set height(h:Number):void
		{
			textField.height = h;
		}
		
		override public function set value(value:*):void
		{
			textField.text = value.split("\\n").join("\n");
			applyTextAttributes();
		}
		
		override public function get value():*
		{
			return textField.text;
		}
		
		private function applyTextAttributes():void
		{
			if (vip.textAttributes)
				TextAttributes.apply(textField, vip.textAttributes);
		}
	}
}