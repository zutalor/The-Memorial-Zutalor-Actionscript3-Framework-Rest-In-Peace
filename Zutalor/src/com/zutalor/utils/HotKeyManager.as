package com.zutalor.utils
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
		private static var inst:HotKeyManager;	
		private var attemptedWordTimeout:Number;		
		private var keyMappings:Dictionary;		
		private var wordMappings:Dictionary;
		private var sequenceMessages:Dictionary;		
		private var sequencesByScope:Dictionary;
		private var tmpDict:Dictionary;
		private var keysDown:String;		

		public function HotKeyManager()
		{
			keyMappings=new Dictionary();
			wordMappings=new Dictionary();
			sequenceMessages=new Dictionary();
			tmpDict=new Dictionary();
			sequencesByScope=new Dictionary();
			keysDown="";
		}
		
		private function init():void
		{
			
		}
		
		/**
		 * Add a keyboard event mapping.
		 * 
		 * <p>There are multiple ways you can add a handler. You can add
		 * handler for a single character, a word or sentence, or a sequence.</p>
		 * 
		 * @example Adding mappings of different types.
		 * <listing>	
		 * km=HotKeyManager.gi();
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
		public function addMapping(obj:*,mapping:String,message:String):void
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
			else 
				addWordMapping(obj, mapping, message);
		}
		
		public function removeMapping(obj:*, mapping:String):void
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
			else 
				removeWordMapping(obj, mapping);
			
			clearKeys();
		}
		
		public function clearKeys():void
		{
			keysDown="";
		}

		// private methods
		
		
		private function isShortcutForKeycode(mapping:String):Boolean
		{
			var keys:String="BACKSPACE+CONTROL+CAPSLOCK+DELETE+DOWN+";
			keys += "END+ENTER+ESC";
			keys += "+HOME+INSERT+LEFT+PAGEDOWN+PAGEUP+RIGHT+SHIFT+SPACE+TAB+UP";
			keys += "NUMPAD0+NUMPAD1+NUMPAD2+NUMPAD3+NUMPAD4+NUMPAD5+NUMPAD6+NUMPAD7+NUMPAD8+NUMPAD9+";
			keys += "NUMPAD_ADD+NUMPAD_DECIMAL+NUMPAD_DIVIDE+NUMPAD_ENTER+NUMPAD_MULTIPLY+NUMPAD_SUBTRACT";
			
			if (keys.indexOf(mapping) > -1) 
				return true;
			else	
				return false;
		}
		
		private function addCharMapping(scope:*, char:String, message:String):void
		{
			if(!keyMappings[scope])
			{
				scope.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false,0,true);
				keyMappings[scope]=new Dictionary();
			}
			keyMappings[scope][char.charCodeAt(0)]=message;	
		}
		
		private function addWordMapping(scope:*, word:String, message:String):void
		{
			if (!wordMappings[scope]) 
			{
				scope.addEventListener(KeyboardEvent.KEY_UP, onKeyUpForWordMapping, false,0,true);
				wordMappings[scope]=new Dictionary();
			}
			wordMappings[scope][word]=message;
		}
		
		private function addSequenceMapping(scope:*,sequence:String,message:String):void
		{
			if(!sequenceMessages[scope])
			{
				scope.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDownForSequence, false, 0, true);
				scope.addEventListener(KeyboardEvent.KEY_UP,onKeyUpForSequence, false, 0, true);
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
		
		private function removeWordMapping(scope:*,word:String):void
		{
			if(!wordMappings[scope])return;
			if(!wordMappings[scope][word])return;
			wordMappings[scope][word]=null;
		}
		
		private function removeSequenceMapping(scope:*, mapping:String):void
		{
			sequenceMessages[scope][mapping]=null;
			//sequenceMessages[scope][mapping]['message']=null;
		}
		
		private function onKeyUp(ke:KeyboardEvent):void
		{
			var scope:* = ke.target.stage;
			if(!keyMappings[scope]) return;

			if (keyMappings[scope][ke.charCode]) 
			{
				dispatchMessage(keyMappings[scope][ke.charCode]);
			}
		}
		
		private function onKeyUpForWordMapping(ke:KeyboardEvent):void
		{
			var scope:* =ke.target.stage;

			if (!tmpDict[scope]) tmpDict[scope] = "";
			tmpDict[scope] += String.fromCharCode(ke.charCode);
			if(wordMappings[scope][tmpDict[scope]])
			{
				dispatchMessage(wordMappings[scope][tmpDict[scope]]);
				tmpDict[scope]="";
			}
				
			clearTimeout(attemptedWordTimeout);
			attemptedWordTimeout=setTimeout(clearAttemptedWord,500,scope);
		}
		
		private function onKeyUpForSequence(ke:KeyboardEvent):void
		{		
			var scope:* =ke.target.stage;
			var char:String = GetShortCut.forKey(ke.keyCode);
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
			var scope:* =ke.target.stage;
			if(!sequenceMessages[scope]) return;
			var char:String=GetShortCut.forKey(ke.keyCode);
			if(char == null) char=String.fromCharCode(ke.charCode);
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
		
		private function clearAttemptedWord(scope:*):void
		{
			tmpDict[scope]="";
		}
		
		private function dispatchMessage(message:String):void
		{
			dispatchEvent(new HotKeyEvent(HotKeyEvent.HOTKEY_PRESS, message));
		}
	}
}