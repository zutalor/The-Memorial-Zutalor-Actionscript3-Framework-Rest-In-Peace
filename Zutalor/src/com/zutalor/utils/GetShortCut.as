package com.zutalor.utils 
{
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Geoff
	 */
	public class GetShortCut
	{
		
		public function GetShortCut() 
		{
			
		}
		
		public static function forKey(keyCode:uint):String
		{
			var char:String=null;
			switch(keyCode)
			{
				case 0:
					break;
				case Keyboard.BACKSPACE:
					char="BACKSPACE";
					break;
				case Keyboard.CONTROL:
					char="CONTROL";
					break;
				case Keyboard.CAPS_LOCK:
					char="CAPSLOCK";
					break;
				case Keyboard.DELETE:
					char="DELETE";
					break;
				case Keyboard.DOWN:
					char="DOWN";
					break;
				case Keyboard.END:
					char="END";
					break;
				case Keyboard.ENTER:
					char="ENTER";
					break;
				case Keyboard.ESCAPE:
					char="ESC";
					break;
				case Keyboard.F1:
					char="F1";
					break;
				case Keyboard.F2:
					char="F2";
					break;
				case Keyboard.F3:
					char="F3";
					break;
				case Keyboard.F4:
					char="F4";
					break;
				case Keyboard.F5:
					char="F5";
					break;
				case Keyboard.F6:
					char="F6";
					break;
				case Keyboard.F7:
					char="F7";
					break;
				case Keyboard.F8:
					char="F8";
					break;
				case Keyboard.F9:
					char="F9";
					break;
				case Keyboard.F10:
					char="F10";
					break;
				case Keyboard.F11:
					char="F11";
					break;
				case Keyboard.F12:
					char="F12";
					break;
				case Keyboard.F13:
					char="F13";
					break;
				case Keyboard.F14:
					char="F14";
					break;
				case Keyboard.F15:
					char="F15";
					break;
				case Keyboard.HOME:
					char="HOME";
					break;
				case Keyboard.INSERT:
					char="INSERT";
					break;
				case Keyboard.LEFT:
					char="LEFT";
					break;
				case Keyboard.PAGE_DOWN:
					char="PAGEDOWN";
					break;
				case Keyboard.PAGE_UP:
					char="PAGEUP";
					break;
				case Keyboard.RIGHT:
					char="RIGHT";
					break;
				case Keyboard.SHIFT:
					char="SHIFT";
					break;
				case Keyboard.SPACE:
					char="SPACE";
					break;
				case Keyboard.TAB:
					char="TAB";
					break;
				case Keyboard.UP:
					char="UP";
					break;
				case Keyboard.NUMPAD_1:
					char="NUMPAD1";
					break;
				case Keyboard.NUMPAD_2:
					char="NUMPAD2";
					break;
				case Keyboard.NUMPAD_3:
					char="NUMPAD3";
					break;
				case Keyboard.NUMPAD_4:
					char="NUMPAD4";
					break;
				case Keyboard.NUMPAD_5:
					char="NUMPAD5";
					break;
				case Keyboard.NUMPAD_6:
					char="NUMPAD6";
					break;
				case Keyboard.NUMPAD_7:
					char="NUMPAD7";
					break;
				case Keyboard.NUMPAD_8:
					char="NUMPAD8";
					break;
				case Keyboard.NUMPAD_9:
					char="NUMPAD9";
					break;
				case Keyboard.NUMPAD_0:
					char="NUMPAD0";
					break;
				case Keyboard.NUMPAD_ADD:
					char="NUMPADADD";
					break;
				case Keyboard.NUMPAD_DECIMAL:
					char="NUMPAD_DECIMAL";
					break;
				case Keyboard.NUMPAD_DIVIDE:
					char="NUMPAD_DIVIDE";
					break;
				case Keyboard.NUMPAD_ENTER:
					char="NUMPAD_ENTER";
					break;
				case Keyboard.NUMPAD_MULTIPLY:
					char="NUMPAD_MULTIPLY";
					break;
				case Keyboard.NUMPAD_SUBTRACT:
					char="NUMPAD_SUBTRACT";
					break;
			}
			return char;
		}		
	}
}