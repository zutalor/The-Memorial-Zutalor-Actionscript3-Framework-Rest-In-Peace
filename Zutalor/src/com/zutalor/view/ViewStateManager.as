package com.zutalor.view
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.controllers.AbstractUXController;
	import com.zutalor.gesture.AppGestureProperties;
	import com.zutalor.gesture.GestureManager;
	import com.zutalor.gesture.GestureProperties;
	import com.zutalor.gesture.GestureTypes;
	import com.zutalor.interfaces.IAcceptsGestureCallbacks;
	import com.zutalor.media.AudioController;
	import com.zutalor.media.MediaPlayer;
	import com.zutalor.media.TextToSpeech;
	import com.zutalor.properties.TranslateItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.TextUtil;
	import com.zutalor.text.Translate;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.GridValues;
	import com.zutalor.utils.HotKeyManager;
	import com.zutalor.utils.MapXML;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.StageRef;
	import flash.events.MediaEvent;
	import flash.system.Capabilities;
	
	public class ViewStateManager implements IAcceptsGestureCallbacks
	{
			
		private var _intitialized:Boolean;		
		private var _nextState:int;
		private var _curStateId:String;
		private var _curState:int;
		
		private var _soundPlayer:MediaPlayer;
		private var _textToSpeech:TextToSpeech;
		private var _hkm:HotKeyManager;
		private var _uxController:AbstractUXController;
		private var _gm:GestureManager;
		private var _gestures:gDictionary;
										
		public function initialize(uxController:AbstractUXController):void
		{
			var params:Array;
			var gs:GraphSettings;				

			if (!_intitialized)
			{
				_intitialized = true;
				_uxController = uxController;
				_gm = new GestureManager();
				_soundPlayer = new MediaPlayer();
				_soundPlayer.initialize("audio", new AudioController());				
			
				_textToSpeech = new TextToSpeech();
				
				if (AirStatus.isMobile)
					_textToSpeech.apiUrl = Props.ap.textToSpeechApiUrlMobile;
				else
					_textToSpeech.apiUrl = Props.ap.textToSpeechApiUrlPC;
					
				_textToSpeech.enabled = Props.ap.enableTextToSpeech;	
				_textToSpeech.voice = "usenglishfemale";
				
				initGestures();
				
				_gm.addCallback(StageRef.stage, GestureTypes.KEY_PRESS, this);
				_gm.addCallback(StageRef.stage, GestureTypes.TAP, this);
				_gm.addCallback(StageRef.stage, GestureTypes.DOUBLE_TAP, this);
				_gm.addCallback(StageRef.stage, GestureTypes.LONG_PRESS, this);
				activateStateByIndex(0);				
			}
		}
		
		public function onGesture(gp:GestureProperties):void
		{
			var width:int = 1024;
			var height:int = 768;
			var rows:int;
			var cols:int;
			var gridValue:GridValues;	
			
			//trace(rows, cols, rows * cols);
			
			gridValue =  MathG.gridIndexQuantizer(gp.result.location.x, gp.result.location.y, 4, 3, width, height);
			trace(gp.result.value, gridValue.row, gridValue.col, gridValue.index);
		}
		
		private function initGestures():void
		{
			var tMeta:XML;
			var appGestures:PropertyManager;
			
			tMeta = getMetaByName("gestures");			
			appGestures = new PropertyManager(AppGestureProperties);
			appGestures.parseXML(tMeta.gestures, "gesture");	
		}
		
		private function stateChange(action:String):void
		{
			var tMeta:XML;					

			switch (String(tMeta.actions.@type))
			{
				case "request" :
					onUserRequest();
					break;
				case "question" :
					onQuestion();
					break;
				case "uxControllerMethod" :
					onUxControllerMethod();
					break;
				case "confirm" :
					onConfirm();
					break;
			}
			
			if (_nextState != _curState)
				activateStateByIndex(_nextState);
				
			function onQuestion():void
			{
				var answered:Boolean = true;
			
				
				if (answered && String(tMeta.question.@next))
				{
					//_hkm.removeEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey);
					//StageRef.stage.removeEventListener(MouseEvent.CLICK, onTap);
					//_hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onConfirmHotKey);
					//StageRef.stage.addEventListener(MouseEvent.CLICK, onConfirmTap);		
				}
				
				/*
				function onConfirmHotKey(hke:HotKeyEvent):void
				{
					resetListeners();
					if (hke.message == RIGHT)
						onConfirmed();
					else
						stateChange(REPEAT);
				}
				
				function onConfirmTap(me:MouseEvent):void
				{
					resetListeners();
					if (translateTapRequest(me) == RIGHT)
						onConfirmed();
					else
						stateChange(REPEAT)
				}
				
				*/
				
				function onConfirmed():void
				{
					activateStateById(String(tMeta.question.@next));
				}
					
				function resetListeners():void
				{
					//_hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey);
					//StageRef.stage.addEventListener(MouseEvent.CLICK, onTap);
					//_hkm.removeEventListener(HotKeyEvent.HOTKEY_PRESS, onConfirmHotKey);
					//StageRef.stage.removeEventListener(MouseEvent.CLICK, onConfirmTap);		
				}
			}
			
			function onUxControllerMethod():void
			{
				
			}
			
			function onUserRequest():void
			{
				var command:String;
				
				//switch (gp.result.value)
				//{
					/*
					case LEFT :
						command = (String(tMeta.actions.@left));
						break;
					case RIGHT :
						command = (String(tMeta.actions.@right));
						break;
					case MIDDLE :
						command = (String(tMeta.actions.@middle));
						*/
				//}
				
				switch (command)
				{
					case "repeat" :
						activateStateByIndex(_curState);
						break;
					case "prev" :
						_nextState--;
						break;
					case "exit" :
						activateStateById("goodbye", _uxController.exit);
						break;
					case "next" :
						_nextState++;
						break;
					case "exit" :
						activateStateById("finish", _uxController.exit);
						break;
				}
			}
	
			function onConfirm():void
			{
				
			}
		}
		
		private function getMetaByName(name:String):XML
		{
			var tp:TranslateItemProperties;
			
			tp = Props.translations.getItemPropsByName(Translate.language, name);
			if (tp)
				return XML(Translate.getMeta(tp.name));
			else
				return null;
		}
		
		private function getMetaByIndex(index:int):XML
		{
			var tp:TranslateItemProperties;
			
			tp = Props.translations.getItemPropsByIndex(Translate.language, index);
			if (tp)
				return XML(Translate.getMeta(tp.name));
			else
				return null;
		}

		private function activateStateById(id:String, onComplete:Function = null):void
		{
			_nextState = Props.translations.getItemIndexByName(Translate.language, id), onComplete
			activateStateByIndex(_nextState, onComplete);
		}
		
		private function activateStateByIndex(index:int, onComplete:Function = null):void
		{
			var tp:TranslateItemProperties;	
			var page:String;
			var forTextToSpeach:String;
			
			_uxController.stop();
			_soundPlayer.stop();		
			tp = Props.translations.getItemPropsByIndex(Translate.language, index);
			_curStateId = tp.name;
			_curState = _nextState;
			
			page = Translate.text(tp.name);
			
			if (AirStatus.isMobile)
				page = TextUtil.stripStringSurroundedByDelimiter(page, "<PC>", "</PC>");
			else
				page = TextUtil.stripStringSurroundedByDelimiter(page, "<MOBILE>", "</MOBILE>");
			
			forTextToSpeach = TextUtil.stripStringSurroundedByDelimiter(page, "<DISPLAYTEXT>", "</DISPLAYTEXT>");
			_uxController.message = TextUtil.stripStringSurroundedByDelimiter(page, "<PHONETIC>", "</PHONETIC>");
			playSound(forTextToSpeach, Translate.getSoundUrl(tp.name), onComplete);
		}
		
		private function playSound(page:String, url:String, onComplete:Function = null):void
		{
			if (page && _textToSpeech.apiUrl)
				_textToSpeech.speak(TextUtil.stripStringSurroundedByDelimiter(page, "<", ">"), onComplete);
			else if (url)
			{
				if (onComplete != null)
					_soundPlayer.addEventListener(MediaEvent.COMPLETE, completed);
				
				_soundPlayer.load(url);
				_soundPlayer.play();
				
				function completed():void
				{
					onComplete();
				}
			}
			else if (onComplete != null)
				onComplete();
		}
	}
}