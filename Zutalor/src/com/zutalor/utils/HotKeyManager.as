﻿package com.zutalor.utils
{
	import com.zutalor.events.HotKeyEvent;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import com.zutalor.utils.Singleton;
	
	
	/**
	 * The HotKeyManager class simplifies working with keyboard events.
	 * Created as part of Guttershark, Modified by GPepos to broadcast an event rather than executing a callback.
	 * and fixed a few bugs.
	 */
	final public class HotKeyManager extends EventDispatcher
	{
		public var keyInvalidated:Boolean;
		private var keyMappings:Dictionary;
		private var sequenceMessages:Dictionary;
		private var sequencesByScope:Dictionary;
		private var tmpDict:Dictionary;
		private var keysDown:String;
		
		private static var _instance:HotKeyManager;

		public function HotKeyManager()
		{
			Singleton.assertSingle(HotKeyManager);
			keyMappings=new Dictionary();
			sequenceMessages=new Dictionary();
			tmpDict=new Dictionary();
			sequencesByScope=new Dictionary();
			keysDown="";
		}
		
		public static function gi():HotKeyManager
		{
			if (!_instance)
				_instance = new HotKeyManager();
			
			return _instance;
		}
		
		/**
		 * Add a keyboard event mapping.
		 *
		 * <p>There are multiple ways you can add a handler. You can add
		 * handler for a single character, or a sequence.</p>
		 *
		 * @example Adding mappings of different types.
		 * <listing>
		 *
		 * km.addMapping(stage,"f", "message");
		 * km.addMapping(stage,"Whatup","message");
		 * km.addMapping(stage,"CONTROL+SHIFT+M", "message");
		 * km.addMapping(stage,"CONTROL+m","message");
		 * km.addMapping(myTextField,"ENTER","message");
		 *
		 * </listing>
		 *
		 * <p><strong>Supported Key Shortcuts for Key Sequences</strong></p>
		 * <ul>
		 * <li>BACKSPACE</li>
		 * <li>CONTROL</li>
		 * <li>CAPSLOCK</li>
		 * <li>DELETE</li>
		 * <li>DOWN</li>
		 * <li>END</li>
		 * <li>ENTER</li>
		 * <li>ESC</li>
		 * <li>F1</li>
		 * <li>F2</li>
		 * <li>F3</li>
		 * <li>F4</li>
		 * <li>F5</li>
		 * <li>F6</li>
		 * <li>F7</li>
		 * <li>F8</li>
		 * <li>F9</li>
		 * <li>F10</li>
		 * <li>F11</li>
		 * <li>F12</li>
		 * <li>F13</li>
		 * <li>F14</li>
		 * <li>F15</li>
		 * <li>HOME</li>
		 * <li>INSERT</li>
		 * <li>LEFT</li>
		 * <li>PAGEDOWN</li>
		 * <li>PAGEUP</li>
		 * <li>RIGHT</li>
		 * <li>SHIFT</li>
		 * <li>SPACE</li>
		 * <li>TAB</li>
		 * <li>UP</li>
		 * <li>NUMPAD1</li>
		 * <li>NUMPAD2</li>
		 * <li>NUMPAD3</li>
		 * <li>NUMPAD4</li>
		 * <li>NUMPAD5</li>
		 * <li>NUMPAD6</li>
		 * <li>NUMPAD7</li>
		 * <li>NUMPAD8</li>
		 * <li>NUMPAD9</li>
		 * <li>NUMPAD0</li>
		 * <li>NUMPAD_ADD</li>
		 * <li>NUMPAD_DIVIDE</li>
		 * <li>NUMPAD_MULTIPLY</li>
		 * <li>NUMPAD_SUBTRACT</li>
		 * <li>NUMPAD_DECIMAL</li>
		 * <li>NUMPAD_ENTER</li>
		 * </ul>
		 *
		 */
		public function  addMapping(obj:*,mapping:String,message:String):void
		{
			if(obj is Array)
			{
				var l:int=obj.length;
				var i:int=0;
				for(i; i < l; i++) addMapping(obj[i],mapping,message);
				return;
			}
			if (mapping.length == 1)
				addCharMapping(obj,mapping,message);
			else if (isShortcutForKeycode(mapping))
				addSequenceMapping(obj,mapping,message);
			else if (mapping.indexOf("+") > -1)
				addSequenceMapping(obj,mapping,message);
		}
		
		public function  removeMapping(obj:*, mapping:String):void
		{
			if(obj is Array)
			{
				var i:int=0;
				var l:int=obj.length;
				for(i;i<l;i++) removeMapping(obj[i],mapping);
			}
			if (mapping.length == 1)
				removeCharMapping(obj, mapping);
			else if (mapping.indexOf("+") > -1)
				removeSequenceMapping(obj, mapping);
			else if (isShortcutForKeycode(mapping))
				removeSequenceMapping(obj,mapping);
		
			clearKeys();
		}
		
		public function  clearKeys():void
		{
			keysDown="";
		}

		
		// private methods
		
		
		private function isShortcutForKeycode(mapping:String):Boolean
		{
			var keys:String="backspace+control+capslock+delete+down+";
			keys += "end+enter+esc";
			keys += "+home+insert+left+pagedown+pageup+right+shift+space+tab+up";
			keys += "numpad0+numpad1+numpad2+numpad3+numpad4+numpad5+numpad6+numpad7+numpad8+numpad9+";
			keys += "numpadAdd+numpadDecimal+numpadDivide+numpadEnter+numpadMultiply+numpadSubtract";
			
			if (keys.indexOf(mapping) > -1)
				return true;
			else
				return false;
		}
		
		private function addCharMapping(scope:*, char:String, message:String):void
		{
			if(!keyMappings[scope])
			{
				scope.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false,int.MAX_VALUE,true);
				keyMappings[scope]=new Dictionary();
			}
			keyMappings[scope][char.charCodeAt(0)]=message;
		}
		
		private function addSequenceMapping(scope:*,sequence:String,message:String):void
		{
			if(!sequenceMessages[scope])
			{
				scope.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDownForSequence, false, int.MAX_VALUE, true);
				scope.addEventListener(KeyboardEvent.KEY_UP,onKeyUpForSequence, false, int.MAX_VALUE, true);
				sequenceMessages[scope]=new Dictionary();
				
			}
			if (!sequenceMessages[scope][sequence])
				sequenceMessages[scope][sequence]=new Dictionary();
			
			sequenceMessages[scope][sequence]['message']=message;
		}
		
		private function removeCharMapping(scope:*, char:String):void
		{
			if (!keyMappings[scope])
				return;
			if (!keyMappings[scope][char])
				return;
			keyMappings[scope][char]=null;
		}
		
		private function removeSequenceMapping(scope:*, mapping:String):void
		{
			sequenceMessages[scope][mapping]=null;
		}
		
		private function onKeyUp(ke:KeyboardEvent):void
		{
			var scope:* = ke.target.stage;
			
			if(!keyMappings[scope]) return;

			if (keyMappings[scope][ke.charCode])
				dispatchMessage(keyMappings[scope][ke.charCode]);
		}
		
		private function onKeyUpForSequence(ke:KeyboardEvent):void
		{
			var scope:* =ke.target.stage;
			var char:String = KeyUtils.shortCutForKeyCode(ke.keyCode);
			if (char == null)
				char=String.fromCharCode(ke.charCode);
			
			var test:String=char+"+";
			var i:int=0;
			
			for(i;i<4;i++)if(keysDown.indexOf(test)>-1)keysDown=keysDown.replace(test,"");
			
			if (!keysDown || keysDown == "")
				return;
			if (!sequenceMessages[scope][keysDown])
				return;
		}
		
		private function onKeyDownForSequence(ke:KeyboardEvent):void
		{
			var scope:* = ke.target.stage;
			keyInvalidated = true;
			
			if(!sequenceMessages[scope]) return;
			var char:String = KeyUtils.shortCutForKeyCode(ke.keyCode);
			if (char == null)
				char=String.fromCharCode(ke.charCode);
			
			var c:String=char+"+";
			if(!keysDown)keysDown="";
			if(keysDown.indexOf(c)>-1)return;
			keysDown+=c;
			var m:String=keysDown.substring(0,keysDown.length-1);
			if (!sequenceMessages[scope][m])
				return;
			if (sequenceMessages[scope][m])
				dispatchMessage(sequenceMessages[scope][m]['message']);
		}
		
		private function dispatchMessage(message:String):void
		{
			keyInvalidated = false;
			dispatchEvent(new HotKeyEvent(HotKeyEvent.HOTKEY_PRESS, message));
		}
	}
}