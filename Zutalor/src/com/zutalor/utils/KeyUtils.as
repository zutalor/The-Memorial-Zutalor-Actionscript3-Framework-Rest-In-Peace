package com.zutalor.utils 
{
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Geoff
	 */
	public class KeyUtils
	{
		
		public static const CONTROL:String = "control";
		public static const SHIFT:String = "shift";
		public static const ALT:String = "alt";
		public static const COMMAND:String = "command";
		
		public static function shortCutForKeyCode(keyCode:uint):String
		{
			var char:String=null;
			switch(keyCode)
			{
				case 0:
					break;
				case Keyboard.BACKSPACE:
					char="backspace";
					break;
				case Keyboard.CONTROL:
					char="control";
					break;
				case Keyboard.CAPS_LOCK:
					char="caplock";
					break;
				case Keyboard.DELETE:
					char="delete";
					break;
				case Keyboard.DOWN:
					char="down";
					break;
				case Keyboard.END:
					char="end";
					break;
				case Keyboard.ENTER:
					char="enter";
					break;
				case Keyboard.ESCAPE:
					char="esc";
					break;
				case Keyboard.F1:
					char="f1";
					break;
				case Keyboard.F2:
					char="f2";
					break;
				case Keyboard.F3:
					char="f3";
					break;
				case Keyboard.F4:
					char="f4";
					break;
				case Keyboard.F5:
					char="f5";
					break;
				case Keyboard.F6:
					char="f6";
					break;
				case Keyboard.F7:
					char="f7";
					break;
				case Keyboard.F8:
					char="f8";
					break;
				case Keyboard.F9:
					char="f9";
					break;
				case Keyboard.F10:
					char="f10";
					break;
				case Keyboard.F11:
					char="f11";
					break;
				case Keyboard.F12:
					char="f12";
					break;
				case Keyboard.F13:
					char="f13";
					break;
				case Keyboard.F14:
					char="f14";
					break;
				case Keyboard.F15:
					char="F15";
					break;
				case Keyboard.HOME:
					char="home";
					break;
				case Keyboard.INSERT:
					char="insert";
					break;
				case Keyboard.LEFT:
					char="left";
					break;
				case Keyboard.PAGE_DOWN:
					char="pagedown";
					break;
				case Keyboard.PAGE_UP:
					char="pageup";
					break;
				case Keyboard.RIGHT:
					char="right";
					break;
				case Keyboard.SHIFT:
					char="shift";
					break;
				case Keyboard.SPACE:
					char="space";
					break;
				case Keyboard.TAB:
					char="tab";
					break;
				case Keyboard.UP:
					char="up";
					break;
				case Keyboard.NUMPAD_1:
					char="numpad1";
					break;
				case Keyboard.NUMPAD_2:
					char="numpad2";
					break;
				case Keyboard.NUMPAD_3:
					char="numpad3";
					break;
				case Keyboard.NUMPAD_4:
					char="numpad4";
					break;
				case Keyboard.NUMPAD_5:
					char="numpad5";
					break;
				case Keyboard.NUMPAD_6:
					char="numpad6";
					break;
				case Keyboard.NUMPAD_7:
					char="numpad7";
					break;
				case Keyboard.NUMPAD_8:
					char="numpad8";
					break;
				case Keyboard.NUMPAD_9:
					char="numpad9";
					break;
				case Keyboard.NUMPAD_0:
					char="numpad0";
					break;
				case Keyboard.NUMPAD_ADD:
					char="numpadAdd";
					break;
				case Keyboard.NUMPAD_DECIMAL:
					char="numpadDecimal";
					break;
				case Keyboard.NUMPAD_DIVIDE:
					char="numpadDivide";
					break;
				case Keyboard.NUMPAD_ENTER:
					char="numpadEnter";
					break;
				case Keyboard.NUMPAD_MULTIPLY:
					char="numpadMultiply";
					break;
				case Keyboard.NUMPAD_SUBTRACT:
					char="numpadSubtract";
					break;
			}
			
			return char;
		}		
	}
}