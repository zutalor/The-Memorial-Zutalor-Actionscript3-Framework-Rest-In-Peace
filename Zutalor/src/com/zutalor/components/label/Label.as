package com.zutalor.components.label 
{
	import com.zutalor.components.interfaces.IViewObject;
	import com.zutalor.components.text.Text;
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
			editable = false;
			textField.selectable = editable = false;
		}
	}
}