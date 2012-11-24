package com.zutalor.components 
{
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.utils.DisplayUtils;
	import flash.display.DisplayObjectContainer;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Label extends InputText implements IViewObject 
	{		
		override public function render(vip:ViewItemProperties):void
		{
			super.render(vip);
			textField.selectable = enabled = false;
		}
		
		public static function addLabel(d:DisplayObjectContainer, text:String = null, textAttributes:String = null, width:int = 0, height:int = 0, align:String=null, hPad:int = 0, vPad:int = 0):void
		{
			var txt:Label = new Label(textAttributes, text);
			if (align)
				DisplayUtils.alignInRect(txt, width, height, align, hPad, vPad);
			txt.name = d.name;	
			d.addChild(txt);
		}
	}
}