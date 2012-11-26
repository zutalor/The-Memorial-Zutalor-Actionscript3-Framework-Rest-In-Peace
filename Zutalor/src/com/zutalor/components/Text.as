package com.zutalor.components 
{
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.text.TextAttributes;
	import com.zutalor.utils.DisplayUtils;
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
			textField = new TextField();
			if (!vip.text)
				vip.text = "";
			textField.text = vip.text;
			applyTextAttributes();
			addChild(textField);
			if (vip.align)
				DisplayUtils.alignInRect(textField, int(vip.width), int(vip.height), vip.align, vip.hPad, vip.vPad);
		}
		
		override public function set value(value:*):void
		{
			textField.text = value;
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