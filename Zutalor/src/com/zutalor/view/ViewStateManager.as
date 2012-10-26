package com.zutalor.view
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.controllers.AbstractUXController;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.media.AudioController;
	import com.zutalor.media.MediaPlayer;
	import com.zutalor.media.TextToSpeech;
	import com.zutalor.properties.TranslateItemProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.TextUtil;
	import com.zutalor.text.Translate;
	import com.zutalor.utils.HotKeyManager;
	import com.zutalor.utils.StageRef;
	import flash.events.MediaEvent;
	import flash.events.MouseEvent;
	
	public class ViewStateManager
	{
		public static const RIGHT:String = "2";
		public static const LEFT:String = "0";
		public static const MIDDLE:String = "1";
		public static const REPEAT:String = "3";		
			
		private var _intitialized:Boolean;		
		private var _nextState:int;
		private var _curStateId:String;
		private var _curState:int;
		
		private var _soundPlayer:MediaPlayer;
		private var _textToSpeech:TextToSpeech;
		private var _hkm:HotKeyManager = HotKeyManager.gi();
		private var _uxController:AbstractUXController;
										
		public function initialize(uxController:AbstractUXController):void
		{
			var params:Array;
			var gs:GraphSettings;				

			if (!_intitialized)
			{
				_intitialized = true;
				_uxController = uxController;
				_soundPlayer = new MediaPlayer();
				_soundPlayer.initialize("audio", new AudioController());				
			
				_textToSpeech = new TextToSpeech();
				
				if (AirStatus.isMobile)
					_textToSpeech.apiUrl = Props.ap.textToSpeechApiUrlMobile;
				else
					_textToSpeech.apiUrl = Props.ap.textToSpeechApiUrlPC;
					
				_textToSpeech.enabled = Props.ap.enableTextToSpeech;	
					
				_textToSpeech.voice = "usenglishfemale";
				
				_hkm.addMapping(StageRef.stage, "LEFT", LEFT);
				_hkm.addMapping(StageRef.stage, "DOWN", MIDDLE);
				_hkm.addMapping(StageRef.stage, "RIGHT", RIGHT);	
				
				_hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey);
				StageRef.stage.addEventListener(MouseEvent.CLICK, onTap);	
				showStateByIndex(0);				
			}
		}
	
		private function stateChange(request:String = null):void
		{
			var tMeta:XML;	
				
			tMeta = getMetaByIndex(_curState);
			
			switch (String(tMeta.actions.@type))
			{
				case "request" :
					handleUserRequest();
					break;
				case "question" :
					handleQuestion();
					break;
				case "simulation" :
					handleSimulation();
					break;
				case "property" :
					handleProperty();
					break;
				case "confirm" :
					handleConfirm();
					break;
			}
			
			if (_nextState != _curState)
				showStateByIndex(_nextState);
				
			function handleQuestion():void
			{
				var answered:Boolean = true;
				
				switch (request)
				{
					case LEFT :
						trace ("answer a");
						playSound("A", "a.mp3");
						break;
					case MIDDLE :
						playSound("B", "b.mp3");
						trace ("answer b");
						break;
					case RIGHT :
						playSound("C", "c.mp3");
						trace ("answer c");
						break;
					default :
						answered = false;
				}
				
				if (answered && String(tMeta.question.@next))
				{
					_hkm.removeEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey);
					StageRef.stage.removeEventListener(MouseEvent.CLICK, onTap);
					_hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onConfirmHotKey);
					StageRef.stage.addEventListener(MouseEvent.CLICK, onConfirmTap);		
				}
				
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
				
				function onConfirmed():void
				{
					showStateById(String(tMeta.question.@next));
				}
					
				function resetListeners():void
				{
					_hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey);
					StageRef.stage.addEventListener(MouseEvent.CLICK, onTap);
					_hkm.removeEventListener(HotKeyEvent.HOTKEY_PRESS, onConfirmHotKey);
					StageRef.stage.removeEventListener(MouseEvent.CLICK, onConfirmTap);		
				}
			}
			
			function handleSimulation():void
			{
				
			}
			
			function handleUserRequest():void
			{
				var command:String;
				
				switch (request)
				{
					case LEFT :
						command = (String(tMeta.actions.@left));
						break;
					case RIGHT :
						command = (String(tMeta.actions.@right));
						break;
					case MIDDLE :
						command = (String(tMeta.actions.@middle));
				}
				
				switch (command)
				{
					case "repeat" :
						showStateByIndex(_curState);
						break;
					case "prev" :
						_nextState--;
						break;
					case "exit" :
						showStateById("goodbye", _uxController.exit);
						break;
					case "next" :
						_nextState++;
						break;
					case "exit" :
						showStateById("finish", _uxController.exit);
						break;
				}
			}
			function handleProperty():void
			{
				
			}
			
			function handleConfirm():void
			{
				
			}
		}
			
		private function onHotKey(hke:HotKeyEvent):void
		{
			stateChange(hke.message);
		}
		
		private function onTap(me:MouseEvent):void
		{
			stateChange(translateTapRequest(me));
		}
			
		private function translateTapRequest(me:MouseEvent):String
		{
			var third:int;
			
			third = StageRef.stage.stageWidth / 3;

			if (me.stageX < third)
			{
				return LEFT;
			}
			else if (me.stageX > third * 2)
			{
				return RIGHT;
			}
			else
				return MIDDLE;
		}			
		
		private function getMetaByIndex(index:int):XML
		{
			var tp:TranslateItemProperties;
			
			tp = Props.translations.getItemPropsByIndex(Translate.language, index);
			return XML(Translate.getMeta(tp.name));
		}

		private function showStateById(id:String, onComplete:Function = null):void
		{
			_nextState = Props.translations.getItemIndexByName(Translate.language, id), onComplete
			showStateByIndex(_nextState, onComplete);
		}
		
		private function showStateByIndex(index:int, onComplete:Function = null):void
		{
			var tp:TranslateItemProperties;	
			var page:String;
			
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
			
			_uxController.message = page;
			playSound(page, Translate.getSoundUrl(tp.name), onComplete);
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