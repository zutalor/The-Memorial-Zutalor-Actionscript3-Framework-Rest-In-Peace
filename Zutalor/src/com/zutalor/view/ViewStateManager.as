package com.zutalor.view
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.application.AppRegistry;
	import com.zutalor.controllers.AbstractUiController;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.gesture.AppGestureEvent;
	import com.zutalor.gesture.GestureMediator;
	import com.zutalor.gesture.GestureTypes;
	import com.zutalor.gesture.UserInputProperties;
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
	import com.zutalor.utils.HotKeyManager;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.ShowError;
	import com.zutalor.utils.SimpleMessage;
	import com.zutalor.utils.StageRef;
	import flash.events.MediaEvent;
	import org.gestouch.gestures.Gesture;
	import org.gestouch.gestures.SwipeGesture;
	
	public class ViewStateManager
	{	
		private var _intitialized:Boolean;
		private var _prevState:int;
		private var _curStateId:String;
		private var _curState:int;
		private var _history:Array;
		private var _curStateText:String;
		private var _curStateMeta:String;
		
		private var _soundPlayer:MediaPlayer;
		private var _textToSpeech:TextToSpeech;
		private var _uiController:AbstractUiController;
		private var _gm:GestureMediator;
		private var _hkm:HotKeyManager;
		private var _gestures:gDictionary;
		private var _answers:gDictionary;
		private var _viewGestures:PropertyManager;
		private var _viewKeyboardInput:PropertyManager;
		private var _dataFromUiController:GenericData;
		private var _transitionNext:String;
		private var _transitionBack:String;
		private var _curTransitionType:String;
		private var _inTransition:Boolean;
		
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
				_gm = new GestureMediator(AppRegistry.gestures);
				_hkm = new HotKeyManager();
				_gm.addEventListener(AppGestureEvent.RECOGNIZED, onGesture);
				_soundPlayer = new MediaPlayer();
				_soundPlayer.initialize("audio", new AudioController());				
				_textToSpeech = new TextToSpeech();
				
				if (AirStatus.isMobile)
					_textToSpeech.apiUrl = Props.ap.textToSpeechApiUrlMobile;
				else
					_textToSpeech.apiUrl = Props.ap.textToSpeechApiUrlPC;
					
				_textToSpeech.enabled = Props.ap.enableTextToSpeech;
				
				initUserInput();
				tMeta = XML(Translate.getMetaByName("settings"));
				
				_transitionNext = tMeta.settings.@transitionNext;
				_transitionBack = tMeta.settings.@transitionBack;
				
				if (tMeta.setttings.@firstPage)
					activateStateById(tMeta.settings.@firstPage);
				else
					activateStateByIndex(0);
			}
		}
				
		private function initUserInput():void
		{
			var tMeta:XML;
			var gp:UserInputProperties;
			var up:UserInputProperties;
			var l:int;
			
			tMeta = XML(Translate.getMetaByName("settings"));
			_viewGestures = new PropertyManager(UserInputProperties);
			_viewGestures.parseXML(tMeta.gestures, "gesture");
			
			l = _viewGestures.length;
			for (var i:int = 0; i < l; i++)
			{
				gp = _viewGestures.getPropsByIndex(i);
				_gm.activateGesture(gp.type, StageRef.stage, gp.name);
			}
			
			_hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey, false, 0, true);
			_viewKeyboardInput = new PropertyManager(UserInputProperties);
			_viewKeyboardInput.parseXML(tMeta.keystrokes, "keystroke");
			l = _viewKeyboardInput.length;
			for (i = 0; i < l; i++)
			{
				up = _viewKeyboardInput.getPropsByIndex(i);
				_hkm.addMapping(StageRef.stage, up.name, up.name);
			}
		}
		
		private function onHotKey(hke:HotKeyEvent):void
		{
			onUserInput(_viewKeyboardInput.getPropsByName(hke.message));
		}
		
		private function onGesture(age:AppGestureEvent):void
		{
			var uip:UserInputProperties;
			
			uip = _viewGestures.getPropsByName(age.name);
			
			SimpleMessage.show(String(age.gesture));
			if (age.gesture is SwipeGesture)
			{
				if (SwipeGesture(age.gesture).offsetX > 1)
					uip.action = uip.actionRight;
				else if (SwipeGesture(age.gesture).offsetY < 1)
					uip.action = uip.actionLeft;
			}
			onUserInput(uip, age.gesture);
		}
		
		private function onUserInput(uip:UserInputProperties, gesture:Gesture = null):void	
		{
			var tMeta:XML;
			tMeta = XML(Translate.getMetaByIndex(_curState));
			switch (String(tMeta.state.@type))
			{
				case "page" :
					checkStateInput();
					break;
				case "question" :
					onAnswer();
					break;
				default :
					break;
			}
				
			function onAnswer():void
			{
				var answer:AnswerProperties;
				var answerText:String;
				var answerIndex:int;
				var qMark:int
				var date:Date = new Date();
			
				if (uip.action == "exit")
					_uiController.exit();
				else if (uip.action == "answer")
				{
					if (uip.type == GestureTypes.TAP)
						answerIndex = getGridValues(gesture, uip).index;
					else if (uip.type == GestureTypes.KEY_PRESS)
						answerIndex = letterAnswers.indexOf(uip.name.toLowerCase());

					answerText = XML(_curStateText)..Q[answerIndex];
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
					
					playSound(answerText, XML(_curStateText)..Q[answerIndex].@sound);
					trace(XML(_curStateText)..Q[answerIndex].@sound, answerText);
				}
				else
					checkStateInput(uip);
			}
			
			function checkStateInput():void
			{				
				_curTransitionType = _transitionNext;
				switch (uip.action)
				{
					case "back" :
						if (String(tMeta.state.@back))
						{
							_curTransitionType = _transitionBack;
							activateStateById(tMeta.state.@back);
						}
						else
						{
							_curTransitionType = null;
							activateStateByIndex(_curState);
						}
						break;
					case "next" :
						if (String(tMeta.state.@next))
							activateStateById(tMeta.state.@next);
						break;		
					case "exit" :
						activateStateById("exit", _uiController.exit);
						break;
					break;
				}
			}
		}	

		private function activateStateById(id:String, onComplete:Function = null, data:GenericData = null):void
		{
			var index:int;
			
			index = Props.translations.getItemIndexByName(Translate.language, id)
			if (index == -1)
				trace("State not found: " + id);
			else
			{
				_dataFromUiController = data;
				activateStateByIndex(index, onComplete);
			}
		}
		
		private function activateStateByIndex(index:int, onComplete:Function = null):void
		{
			var tp:TranslateItemProperties;	
			var page:String;
			var forTextToSpeech:String;
			var next:String;

			if (!_inTransition)
			{
				_inTransition = true;
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
				
				forTextToSpeech = TextUtil.stripSurroundedBy(page, "<DISPLAYTEXT>", "</DISPLAYTEXT>");

				_uiController.getValueObject().text = TextUtil.stripSurroundedBy(page, "<PHONETIC>", "</PHONETIC>");
							_uiController.onModelChange(null, _curTransitionType, onTransitionComplete );
			}
		
			function onTransitionComplete():void
			{
				_inTransition = false;
				_prevState = _curState;				
				if (XML(tp.tMeta).state.@type == "prompt")
				{
					next = XML(tp.tMeta).state.@next;
					if (next)
						onComplete = activateStateById;
				}
				else if (XML(tp.tMeta).state.@type == "uiControllerMethod")
					_uiController[XML(tp.tMeta).state.@method](activateStateById, XML(tp.tMeta).state);	
		
				playSound(forTextToSpeech, Translate.getSoundName(tp.name), onComplete, next);
			}
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
		
		
		private function getGridValues(gesture:Gesture, uip:UserInputProperties):GridValues
		{
			return MathG.gridIndexQuantizer(gesture.location.x, gesture.location.y, 
						uip.cols, uip.rows, StageRef.stage.stageWidth, StageRef.stage.stageHeight);					
		}
	}
}