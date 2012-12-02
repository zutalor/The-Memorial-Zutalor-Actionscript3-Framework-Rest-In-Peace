package com.zutalor.components.label 
{
	import com.zutalor.components.interfaces.IViewObject;
	import com.zutalor.components.text.Text;
		import com.zutalor.view.properties.ViewItemProperties;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Label extends Text implements IViewObject 
	{
		public function Label(name:String)
		{
			super(name);
		}

		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			super.render(viewItemProperties);
			editable = false;
			textField.selectable = editable = false;
		}
	}
}