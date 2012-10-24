package com.zutalor.ui
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.events.UIEvent;
	import com.zutalor.ui.Button
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Toggle extends Sprite implements IDisposable
	{
		private var _onState:Button;
		private var _offState:Button;
		
		private var _value:Boolean;
		
		public function Toggle()
		{
			
		}
		
		public function create(onState:Button, offState:Button):void 
		{
			addChild(onState);
			addChild(offState);
			_onState = onState;
			_offState = offState;
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
		
		private function onMouseDown(me:MouseEvent):void
		{
			if (_value)
				_value = false;
			else
				_value = true;
			
			toggle();
			dispatchEvent(new UIEvent(UIEvent.VALUE_CHANGED, null, null, null, _value));						
		}
		
		public function set value(v:Boolean):void
		{
			_value = v;
			toggle();	
		}
		
		private function toggle():void
		{
			if (_value) 
			{
				_onState.visible = true;
				_offState.visible = false;
			}
			else
			{
				_onState.visible = false;
				_offState.visible = true;
			}
		}				
		
		public function get value():Boolean
		{
			if (_value)
				return true;
			else
				return false;
		}

		public function set enabled(en:Boolean):void
		{
			_onState.enabled = en;
			_offState.enabled = en;
		}
		
		public function dispose():void
		{
			removeChildAt(0);
			removeChildAt(0);
			_onState = null;
			_offState = null;
		}
	}
}