package com.zutalor.components 
{
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.text.TextAttributes;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff
	 */
	public class InputText extends Component implements IComponent 
	{		
		
		public var textField:TextField;
		
		override public function render(vip:ViewItemProperties):void
		{
			textField = new TextField();
			textField.text = vip.text;
			applyTextAttributes();
			addChild(textField);
		}
		
		public function applyTextAttributes():void
		{
			TextAttributes.apply(textField, vip.textAttributes);
		}
		
		override public function set value(value:*):void
		{
			textField.text = value;
		}
		
		override public function get value():*
		{
			return textField.text;
		}
	}
}