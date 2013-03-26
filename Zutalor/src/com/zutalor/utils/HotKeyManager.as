package com.zutalor.utils
{
	import com.zutalor.events.HotKeyEvent;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.external.ExternalInterface;
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
		private var keyUpRegistry:gDictionary
		
		public var scope:DisplayObject;
		
		private static var _instance:HotKeyManager;

		public function HotKeyManager()
		{
			Singleton.assertSingle(HotKeyManager);
			init();
		}
		
		private function init():void
		{
			keyMappings=new Dictionary();
			sequenceMessages=new Dictionary();
			tmpDict=new Dictionary();
			sequencesByScope=new Dictionary();
			keysDown = "";
			keyUpRegistry = new gDictionary();
			scope = StageRef.stage;
			
			if (ExternalInterface.available)
			{
				Logger.eTrace("adding callback");
				ExternalInterface.addCallback('keyEvent',keyEvent);
			}
		}
		
		public function registerOnKeyUp(callback:Function):void
		{
			keyUpRegistry.insert(callback, callback);
		}
		
		public function unregisterOnKeyUp(callback:Function):void
		{
			keyUpRegistry.deleteByKey(callback);
		}
		
		//this is called from JS in the web page.
		private function keyEvent(keycode:String, charCode:String, ctrlPressed:String, altPressed:String,
																	shiftPressed:String, keyDown:String):void
		{
			var ke:KeyboardEvent;
			var type:String;
			var alt:Boolean;
			var ctrl:Boolean;
			var shift:Boolean;
			var char:String;
			
			if (altPressed == "true")
				alt = true;
			if (ctrlPressed == "true")
				ctrl = true;
			if (shiftPressed == "true")
				shift = true;
			
			if (keyDown == "true")
				type = KeyboardEvent.KEY_DOWN;
			else
				type = KeyboardEvent.KEY_UP;
			
				
			if (!shift && charCode)
			{
				
				char = String.fromCharCode(charCode);
				if (char)
					charCode = String(char.toLowerCase().charCodeAt(0));
					
				Logger.eTrace(charCode);

			}
			
			ke = new KeyboardEvent(type, true, false, uint(charCode), uint(keycode), 0, ctrl, alt, shift);
			
			if (type == KeyboardEvent.KEY_DOWN)
				onKeyDownForSequence(ke);
			else
			{
				Logger.eTrace("Key: " + keycode + " " + charCode + " " + ctrlPressed + " " + shiftPressed);
				onKeyUp(ke);
				onKeyUpForSequence(ke);
			}
			
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
		 *
		 */
		public function  addMapping(mapping:String,message:String):void
		{
			if (mapping.length == 1)
				addCharMapping(mapping, message);
			else if (isShortcutForKeycode(mapping))
				addSequenceMapping(mapping,message);
			else if (mapping.indexOf("+") > -1)
				addSequenceMapping(mapping,message);
		}
		
		public function  removeMapping(mapping:String):void
		{
			if (mapping.length == 1)
				removeCharMapping(mapping);
			else if (mapping.indexOf("+") > -1)
				removeSequenceMapping(mapping);
			else if (isShortcutForKeycode(mapping))
				removeSequenceMapping(mapping);
		
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
			keys += "numpadadd+numpaddecimal+numpaddivide+numpadenter+numpadmultiply+numpadsubtract";
			
			if (keys.indexOf(mapping) > -1)
				return true;
			else
				return false;
		}
		
		private function addCharMapping(char:String, message:String):void
		{
			if(!keyMappings[scope])
			{
				scope.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false,int.MAX_VALUE,true);
				keyMappings[scope]=new Dictionary();
			}
			keyMappings[scope][char.charCodeAt(0)]=message;
		}
		
		private function addSequenceMapping(sequence:String,message:String):void
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
		
		private function removeCharMapping(char:String):void
		{
			if (!keyMappings[scope])
				return;
			if (!keyMappings[scope][char])
				return;
			keyMappings[scope][char]=null;
		}
		
		private function removeSequenceMapping(mapping:String):void
		{
			sequenceMessages[scope][mapping]=null;
		}
		
		private function onKeyUp(ke:KeyboardEvent):void
		{
			if(keyMappings[scope] && keyMappings[scope][ke.charCode])
				dispatchMessage(keyMappings[scope][ke.charCode]);
				
			callOnKeyUp(ke);
		}
		
		private function callOnKeyUp(ke:KeyboardEvent):void
		{
			var keyUpFunc:Function;
			
			for (var i:int = 0; i < keyUpRegistry.length; i++)
			{
				keyUpFunc = keyUpRegistry.getByIndex(i) as Function;
				if (keyUpFunc != null)
					keyUpFunc(ke);
			}
		}
		
		private function onKeyUpForSequence(ke:KeyboardEvent):void
		{
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