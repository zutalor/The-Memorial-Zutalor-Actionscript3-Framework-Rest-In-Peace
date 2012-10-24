package com.zutalor.ui  
{
	import com.zutalor.containers.Container;
	import com.zutalor.containers.MaskedContainer;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Menu extends Sprite
	{
		private var _horizontal:Boolean;
		private var _width:int;
		private var _height:int;
		private var _leading:int;
		private var _menuContainer:MaskedContainer;
		
		public function Menu(width:int, height:int, leading:int) 
		{
			_width = width;
			_height = height;
			_leading = leading;				
			init();
		}
		
		private function init():void
		{
			_menuContainer = new MaskedContainer(this.name, _width, _height);
			addChild(_menuContainer);
		}
				
		public function exists(name:String):Boolean
		{
			if (_menuContainer.contentLayer.getChildByName(name))
				return true;
			else
				return false;
		}	
		
		public function addItemToMenu(item:DisplayObject, name:String, isHeading:Boolean):void
		{
			var s:Sprite = new Sprite();
			s.name = name.toLowerCase();
			if (!isHeading)
				s.buttonMode = true;
			s.addChild(item);
			_menuContainer.push(s);
		}
		
		public function addTextItemToMenu(label:String, isHeading:Boolean, indent:Number, options:*=null):void
		{
			var textButton:TextButton = new TextButton();
			textButton.create(label, _width, 30, isHeading, indent);
			textButton.name = label;
			_menuContainer.push(textButton);
		}
		
		public function get contentContainer():Container
		{
			return _menuContainer;
		}
		
	}	
}