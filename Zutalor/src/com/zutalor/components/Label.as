package com.zutalor.components 
{
	import com.zutalor.properties.ViewItemProperties;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Label extends Text implements IViewObject 
	{		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super.render(viewItemProperties);
			textField.selectable = enabled = false;
		}
	}
}