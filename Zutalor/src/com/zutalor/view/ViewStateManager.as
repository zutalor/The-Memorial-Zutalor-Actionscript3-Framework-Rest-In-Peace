package com.zutalor.view
{

	import com.zutalor.air.AirStatus;
	import com.zutalor.controllers.AbstractUiController;
	import com.zutalor.gesture.AppGestureProperties;
	import com.zutalor.gesture.GestureManager;
	import com.zutalor.gesture.GestureProperties;
	import com.zutalor.gesture.GestureTypes;
	import com.zutalor.interfaces.IAcceptsGestureCallbacks;
	import com.zutalor.media.AudioController;
	import com.zutalor.media.MediaPlayer;
	import com.zutalor.media.TextToSpeech;
	import com.zutalor.misc.AnswerProperties;
	import com.zutalor.misc.GenericData;
	import com.zutalor.properties.TranslateItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.TextUtil;
	import com.zutalor.text.Translate;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.GridValues;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.ShowError;
	import com.zutalor.utils.StageRef;
	import flash.events.MediaEvent;
	
	public class ViewStateManager implements IAcceptsGestureCallbacks
	{
			
		private var _intitialized:Boolean;		
		private var _curStateId:String;
		private var _curState:int;
		private var _history:Array;
		private var _curStateText:String;
		private var _curStateMeta:String;
		
		private var _soundPlayer:MediaPlayer;
		private var _textToSpeech:TextToSpeech;
		private var _uiController:AbstractUiController;
		private var _gm:GestureManager;
		private var _gestures:gDictionary;
		private var _answers:gDictionary;
		private var _appGestures:PropertyManager;
		private var _dataFromUiController:GenericData;
		
		private static const soundExt:String = ".mp3";
		private static const letterAnswers:String = "abcdefgh";
		
										
		public function initialize(uiController:AbstractUiController):void
		{
			var l:int;
			var gs:GraphSettings;
			var tMeta:XML;

			if (!_intitialized)
			{
				_intitialized = true;
				_uiController = uiController;
				_answers = new gDictionary();
				_history = [];
				_gm = new GestureManager();
				_soundPlayer = new MediaPlayer();
				_soundPlayer.initialize("audio", new AudioController());				
				_textToSpeech = new TextToSpeech();
				
				if (AirStatus.isMobile)
					_textToSpeech.apiUrl = Props.ap.textToSpeechApiUrlMobile;
				else
					_textToSpeech.apiUrl = Props.ap.textToSpeechApiUrlPC;
					
				_textToSpeech.enabled = Props.ap.enableTextToSpeech;
				
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
				_gm.addCallback(StageRef.stage, agp.name, agp.gestureType, this);
			}
		}
		
		public function onGesture(gp:GestureProperties):void
		{
			var gridValues:GridValues;
			var agp:AppGestureProperties;			
			var tMeta:XML;		
			
			agp = _appGestures.getPropsByName(gp.result.value);
			
			if (agp)
			{
				gridValues = getGridValues(gp, agp);
				tMeta = getMetaByIndex(_curState);
				
				switch (String(tMeta.state.@type))
				{
					case "page" :
						activateNextState();
						break;
					case "question" :
						onAnswer();
						break;
					default :
						break;
				}
			}
				
			function onAnswer():void
			{
				var answer:AnswerProperties;
				var answerText:String;
				var index:int;
				var qMark:int
				var date:Date = new Date();
			
				if (agp.action == "exit")
					activateNextState();
				else if (agp.action == "answer")
				{
					if (agp.gestureType == GestureTypes.TAP)
						index = gridValues.index;
					else if (agp.gestureType == GestureTypes.KEY_PRESS)
						index = letterAnswers.indexOf(gp.result.value.toLowerCase().toLowerCase());

					answerText = XML(_curStateText)..Q[index];
					qMark = answerText.indexOf("?");
					if (qMark != -1)
						answerText = answerText.substring(0, qMark);
						
					answer = new AnswerProperties();
					answer.answer = answerText.substr(0, 1).toUpperCase();
					answer.questionId = _curStateId;
					answer.correctAnswer = XML(_curStateText)..answers.@correctAnswer;
					answer.timestamp = date.toString();
					
					if (_dataFromUiController)
					{
						answer.data = _dataFromUiController.data;
						_answers.insert(_dataFromUiController.name, answer);	
					}
					else
						_answers.insert(_curStateId, answer);
					
					playSound(answerText, XML(_curStateText)..Q[index].@sound);
					trace(XML(_curStateText)..Q[index].@sound, answerText);
				}
				else
				{
					activateNextState();
				}
			}
			
			function activateNextState():void
			{				
				switch (agp.action)
				{
					case "back" :
						activateStateByIndex(_curState);
						break;
					case "next" :
						if (String(tMeta.state.@next))
							activateStateById(tMeta.state.@next);
						break;						
					case "exit" :
						activateStateById("goodbye", _uiController.exit);
						break;
				}
			}	
		}

		private function activateStateById(id:String, onComplete:Function = null, data:GenericData = null):void
		{
			var index:int;
			
			index = Props.translations.getItemIndexByName(Translate.language, id)
			if (index == -1)
				ShowError.fail(ViewStateManager,"State not found: " + id);
			
			_dataFromUiController = data;
			activateStateByIndex(index, onComplete);
		}
		
		private function activateStateByIndex(index:int, onComplete:Function = null):void
		{
			var tp:TranslateItemProperties;	
			var page:String;
			var fortextToSpeech:String;
			var next:String;

			stop();
			
			tp = Props.translations.getItemPropsByIndex(Translate.language, index);
			_curStateId = tp.name;
			_curState = index;
			_history.push(_curState);
			
			page = Translate.text(tp.name);
			_curStateText = page;
			
			if (AirStatus.isMobile)
				page = TextUtil.stripSurroundedBy(page, "<PC>", "</PC>");
			else
				page = TextUtil.stripSurroundedBy(page, "<MOBILE>", "</MOBILE>");
				
			page = TextUtil.stripSurroundedBy(page, "<hide>", "</hide>");
			
			fortextToSpeech = TextUtil.stripSurroundedBy(page, "<DISPLAYTEXT>", "</DISPLAYTEXT>");
			_uiController.message = TextUtil.stripSurroundedBy(page, "<PHONETIC>", "</PHONETIC>");
				
			if (XML(tp.tMeta).state.@type == "prompt")
			{
				next = XML(tp.tMeta).state.@next;
				if (next)
					onComplete = activateStateById;
			}
			else if (XML(tp.tMeta).state.@type == "uiControllerMethod")
				_uiController[XML(tp.tMeta).state.@method](activateStateById, XML(tp.tMeta).state);	
	
			playSound(fortextToSpeech, Translate.getSoundName(tp.name), onComplete, next);
		}
		
		private function playSound(page:String, soundName:String, onComplete:Function = null, onCompleteParams:*=null):void
		{
			
			if (page && _textToSpeech.apiUrl)
				_textToSpeech.speak(TextUtil.stripSurroundedBy(page, "<", ">"), checkOnComplete);
			else if (soundName)
			{
				if (onComplete != null)
					_soundPlayer.addEventListener(MediaEvent.COMPLETE, checkOnComplete);
				
				_soundPlayer.load(soundName + soundExt);
				_soundPlayer.play();
			}
			else
				checkOnComplete();

			function checkOnComplete():void
			{
				if (onComplete != null)
					if (onCompleteParams)
						onComplete(onCompleteParams);
					else
						onComplete();
			}
		}
		
		private function stop():void
		{
			_textToSpeech.stop();			
			_uiController.stop();
			_soundPlayer.stop();
		}
		
		// UTILITY
		
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
		
		private function getGridValues(gp:GestureProperties, agp:AppGestureProperties):GridValues
		{
			return MathG.gridIndexQuantizer(gp.result.location.x, gp.result.location.y, 
						agp.cols, agp.rows, StageRef.stage.stageWidth, StageRef.stage.stageHeight);					
		}
	}
}