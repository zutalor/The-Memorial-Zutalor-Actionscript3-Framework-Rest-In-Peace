/**
 * ...
 * @author Justin Windle [www.soulwire.co.uk]
 * @version 0.1
 */

package com.soulwire.g94menu 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import fl.transitions.Tween;
	import fl.transitions.*;
	import fl.transitions.easing.*;

	public class G94Menu extends Sprite
	{
		
		//- PRIVATE VARIABLES -------------------------------------------------------------------------------------
		
		// Variable                    // Data Type
		
		private var _items:            Array = new Array();
		private var _visItems:         int;
		private var _spacing:          int;
		private var _offset:           int;
		private var _position:         int;
		
		//- PUBLIC VARIABLES --------------------------------------------------------------------------------------
		
		// Variable                    // Data Type
		
		//- CONSTRUCTOR	-------------------------------------------------------------------------------------------
		
		public function G94Menu(visItems:int, spacing:int, offset:int) 
		{
			_position = 0;
			_visItems = visItems;
			_spacing = spacing;
			_offset = offset;
		}
		
		//- PRIVATE METHODS ---------------------------------------------------------------------------------------
		
		private function sort():void
		{
			var _y:int;
			
			var min:int = _position;
			var max:int = _position + _visItems;
			
			for(var i:int = 0; i < _items.length; i++)
			{
				var mc:MenuItem = _items[i];
				var alph:int = Number(i >= min && i < max);
				var yPos:int = mc.id * (mc.height + _spacing);
				var yTar:int = _position * (_spacing + mc.height);
				
				if(i < min)
				{
					_y = yPos - _offset - yTar;
				}
				else if (i >= max)
				{
					_y = yPos + _offset - yTar;
				}
				else
				{
					_y = yPos - yTar;
				}
				
				new Tween(mc, 'y', Regular.easeInOut, mc.y, _y, 8);
				new Tween(mc, 'alpha', Regular.easeInOut, mc.alpha, alph, 8);
			}
		}
		
		//- PUBLIC METHODS ----------------------------------------------------------------------------------------
		
		public function addItem(item:MenuItem):void
		{
			item.y = (item.height + _spacing) * _items.length;
			item.init(_items.length, _items.length >= _position && _items.length < _position + _visItems);
			
			_items.push(item);
			addChild(item);
			sort();
		}
	
		public function scrollUp(e:MouseEvent = null):void
		{
			if(_position <= 0){return};
			_position--;
			sort();
		}
		
		public function scrollDown(e:MouseEvent = null):void
		{
			if(_position >= _items.length - _visItems){return};
			_position++;
			sort();
		}
				
		//- EVENT HANDLERS ----------------------------------------------------------------------------------------
		
		//- GETTERS & SETTERS -------------------------------------------------------------------------------------
		
		//- HELPERS -----------------------------------------------------------------------------------------------
		
		//- END CLASS ---------------------------------------------------------------------------------------------
		
	}
	
}
