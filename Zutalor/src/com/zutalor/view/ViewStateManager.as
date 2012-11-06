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
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.StageRef;
	import flash.events.MediaEvent;
	
	public class ViewStateManager implements IAcceptsGestureCallbacks
	{
			
		private var _intitialized:Boolean;		
		private var _nextState:int;
		private var _curStateId:String;
		private var _curState:int;
		private var _curStateText:String;
		private var _curStateMeta:String;
		
		private var _soundPlayer:MediaPlayer;
		private var _textToSpeech:TextToSpeech;
		private var _hkm:HotKeyManager;
		private var _uxController:AbstractUXController;
		private var _gm:GestureManager;
		private var _gestures:gDictionary;
		private var _appGestures:PropertyManager;
		
		private static const soundExt:String = ".mp3";
										
		public function initialize(uxController:AbstractUXController):void
		{
			var l:int;
			var gs:GraphSettings;
			var tMeta:XML;

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
				
				tMeta = getMetaByName("settings");
				
				if (tMeta.setttings.@firstPage)
					activateStateById(tMeta.settings.@firstPage);
				else
					activateStateByIndex(0);
			}
		}
				
		private function initGestures():void
		{
			var tMeta:XML;
			var agp:AppGestureProperties;
			var l:int;
			
			tMeta = getMetaByName("settings");
			_appGestures = new PropertyManager(AppGestureProperties);
			_appGestures.parseXML(tMeta.gestures, "gesture");
			
			l = _appGestures.length;
			for (var i:int = 0; i < l; i++)
			{
				agp = _appGestures.getPropsByIndex(i);
				_gm.addCallback(StageRef.stage, agp.name, agp.type, this);
			}
		}
		
		public function onGesture(gp:GestureProperties):void
		{
			var gridValue:GridValues;
			var agp:AppGestureProperties;			
			var tMeta:XML;		
			
			agp = _appGestures.getPropsByName(gp.result.value);
			
			if (agp)
			{
				gridValue = getGridValues(gp, agp);
				tMeta = getMetaByIndex(_curState);
				

				switch (String(tMeta.state.@type))
				{
					case "page" :
						onPageGesture();
						break;
					case "uxControllerMethod" :
						onUxControllerMethod();
						break;
					case "question" :
						onQuestionGesture();
						break;
					default :
						break;
				}
				
				if (_nextState != _curState)
					activateStateByIndex(_nextState);
			}
				
			function onPageGesture():void
			{				
				switch (agp.request)
				{
					case "back" :
						activateStateByIndex(_curState);
						break;
					case "next" :
						activateStateById(tMeta.state.@next);
						break;						
					case "exit" :
						activateStateById("goodbye", _uxController.exit);
						break;
					case "exit" :
						activateStateById("finish", _uxController.exit);
						break;
				}
			}				
				
			function onQuestionGesture():void
			{
				trace(XML(_curStateText).P.questions.Q[2]);
					
			}
			
			function onUxControllerMethod():void
			{
				
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
			_nextState = Props.translations.getItemIndexByName(Translate.language, id);
			activateStateByIndex(_nextState, onComplete);
		}
		
		private function tTextByPageId(id:String):String
		{ 
			return Props.translations.getItemPropsByName(Translate.language, id).tText;
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
			_curStateText = page;
			
			if (AirStatus.isMobile)
				page = TextUtil.stripStringSurroundedByDelimiter(page, "<PC>", "</PC>");
			else
				page = TextUtil.stripStringSurroundedByDelimiter(page, "<MOBILE>", "</MOBILE>");
			
			forTextToSpeach = TextUtil.stripStringSurroundedByDelimiter(page, "<DISPLAYTEXT>", "</DISPLAYTEXT>");
			_uxController.message = TextUtil.stripStringSurroundedByDelimiter(page, "<PHONETIC>", "</PHONETIC>");
			playSound(forTextToSpeach, Translate.getSoundName(tp.name), onComplete);
		}
		
		private function playSound(page:String, soundName:String, onComplete:Function = null):void
		{
			if (page && _textToSpeech.apiUrl)
				_textToSpeech.speak(TextUtil.stripStringSurroundedByDelimiter(page, "<", ">"), onComplete);
			else if (soundName)
			{
				
				if (onComplete != null)
					_soundPlayer.addEventListener(MediaEvent.COMPLETE, completed);
				
				_soundPlayer.load(soundName + soundExt);
				_soundPlayer.play();
				
				function completed():void
				{
					onComplete();
				}
			}
			else if (onComplete != null)
				onComplete();
		}
		
		
		private function getGridValues(gp:GestureProperties, agp:AppGestureProperties):GridValues
		{
			return MathG.gridIndexQuantizer(gp.result.location.x, gp.result.location.y, 
						agp.cols, agp.rows, StageRef.stage.stageWidth, StageRef.stage.stageHeight);					
		}
	}
}