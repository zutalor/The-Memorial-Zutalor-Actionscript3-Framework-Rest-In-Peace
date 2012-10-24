package com.zutalor.ui
{
	import com.zutalor.text.TextUtil;
	import com.zutalor.ui.ButtonStates;
	import com.zutalor.ui.DrawGraphics;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class TextButton extends Sprite
	{
		private var _sb:SimpleButton;
		private var _bs:ButtonStates = new ButtonStates();		
		
		public function TextButton()
		{
			
		}
		
		public function create(label:String, width:int, height:int, isHeader:Boolean = false, indent:Number = 0, 
									textAttributesUp:String = "menu-up", textAttributesOver:String = "menu-over", 
									textAttributesDown:String = "menu-down", textAttributesSelected:String = "menu-selected", 
									textAttributesDisabled:String = "menu-disabled", textAttributesMenuHeading:String = "menu-heading" ):void
		{
			var txt:TextField;

			_sb = new SimpleButton(_bs.up, _bs.over, _bs.down, _bs.hit);
			_sb.name = name;
			addChild(_sb);
			
			txt = new TextField();
			txt.text = label;			
			if (isHeader)
			    TextUtil.applyTextAttributes(txt,textAttributesMenuHeading) 
			else	
			    TextUtil.applyTextAttributes(txt,textAttributesUp) 
				
			_bs.up.addChild(txt);
			_bs.up.x = indent;
			
			txt = new TextField();
			txt.text = label;
			TextUtil.applyTextAttributes(txt,textAttributesOver) 
			_bs.over.addChild(txt);
			_bs.over.x = indent;
			
			txt = new TextField();
			txt.text = label;
			TextUtil.applyTextAttributes(txt,textAttributesDown) 
			_bs.down.addChild(txt);
			_bs.down.x = indent;
			
			if (!isHeader)
				DrawGraphics.box(_bs.hit, _bs.up.width, _bs.up.height);			
		}
		
		public function set enabled(e:Boolean):void
		{
			_sb.enabled = _sb.mouseEnabled = e;
			if (e)
				_sb.overState = _bs.disabled;
			else
				_sb.overState = _bs.over;
		}
		
		public function get enabled():Boolean
		{
			return _sb.enabled;
		}
	}
}