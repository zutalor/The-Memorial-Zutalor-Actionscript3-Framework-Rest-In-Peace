package com.zutalor.view.mediators
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.components.media.audio.AudioPlayer;
	import com.zutalor.controllers.AbstractUiController;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.gesture.AppGestureEvent;
	import com.zutalor.gesture.GestureMediator;
	import com.zutalor.gesture.UserInputProperties;
	import com.zutalor.media.TextToSpeech;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.TranslateItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.text.TextUtil;
	import com.zutalor.text.Translate;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.GridValues;
	import com.zutalor.utils.HotKeyManager;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.SimpleMessage;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.properties.AnswerProperties;
	import com.zutalor.view.properties.GenericData;
	import org.gestouch.gestures.Gesture;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.TapGesture;

	
	public class ViewStateMediator
	{	
		private var _prevState:int;
		private var _curStateId:String;
		private var _curAnswerKey:String;
		private var _curState:int;
		private var _history:Array;
		private var _curStateText:String;
		private var _curStateMeta:String;
		private var _textToSpeech:TextToSpeech;
		private var _audioPlayer:AudioPlayer;
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
		
		private var _loopCount:int;
		private var _questions:Array;
		private var _currentQuestion:int;
		private var _loops:int;
		private var _onCompleteState:String;

		
		private static const soundExt:String = ".mp3";
		private static const letterAnswers:String = "abcdefgh";
		
		public function ViewStateMediator(uiController:AbstractUiController)
		{
			_uiController = uiController;
			init();
		}
										
		private function init():void
		{
			var l:int;
			var gs:GraphSettings;
			var tMeta:XML;
		
			_answers = new gDictionary();
			_history = [];
			_gm = GestureMediator.gi();
			_hkm = HotKeyManager.gi();
			_gm.addEventListener(AppGestureEvent.RECOGNIZED, onGesture);
			_audioPlayer = new AudioPlayer("audio");				
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
		
		public function onUiControllerMethodCompleted(args:XMLList, data:GenericData):void
		{
			_dataFromUiController = data;
			if (!_loopCount)
			{
				_questions = args.@questions.split(",");
				_loops = args.@loop;
				_onCompleteState = args.@onCompleteState;
				questionLoop();
			}
		}
		
		// PRIVATE METHODS
		
		private function questionLoop():void
		{
			if (_loopCount == _loops)
			{
				_loopCount = 0;
				activateStateById(_onCompleteState);
			}
			else if (_loopCount < _loops)
			{
				if (_currentQuestion < _questions.length)
				{
					_dataFromUiController.name = (_loopCount + 1) + " - " + _questions[_currentQuestion];
					activateStateById(_questions[_currentQuestion++]);
				}
				if (_currentQuestion == _questions.length)
				{
					++_loopCount;
					_currentQuestion = 0;
				}
			}
		}
		
		private function activateStateById(id:String):void
		{
			var index:int;
			
			index = Translate.presets.getItemIndexByName(Translate.language, id)
			if (index == -1)
				trace("State not found: " + id);
			else 
				activateStateByIndex(index);
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
				case "exit" :
					_uiController.exit();
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
					if (uip.type == Plugins.getClassName(TapGesture))
						answerIndex = getGridValues(gesture, uip).index;
					else
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
						_curAnswerKey = answer.questionId = _dataFromUiController.name;
						answer.data = _dataFromUiController.data;
					}
					else
						_curAnswerKey = _curStateId;
						
					_answers.insert(_curAnswerKey, answer);
					playSound(answerText, XML(_curStateText)..Q[answerIndex].@sound);
				}
				else
				{
					if (_answers.getByKey(_curAnswerKey))
					{
						checkStateInput(uip);
						_curAnswerKey = null;
					}
				}
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
						if (String(tMeta.state.@next) == "question")
							questionLoop();
						else if (String(tMeta.state.@next) == "exit")
							_uiController.exit();
						else
							activateStateById(tMeta.state.@next);
						break;		
					case "questionLoop" :
						questionLoop();
						break;
					default :
						break;
				}
			}
		}
				
		private function activateStateByIndex(index:int):void
		{
			var tp:TranslateItemProperties;	
			var page:String;
			var forTextToSpeech:String;
			var next:String;

			if (!_inTransition)
			{
				_inTransition = true;
				stop();
				tp = Translate.presets.getItemPropsByIndex(Translate.language, index);
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
				
				switch (String(XML(tp.tMeta).state.@type))
				{	
					case "uiControllerMethod" :
						_uiController[XML(tp.tMeta).state.@method](XML(tp.tMeta).state);	
						break;
					case "submitAnswers" :
						var ap:AnswerProperties;
						for (var i:int = 0; i < _answers.length; i++)
						{
							ap = _answers.getByIndex(i);
							trace(ap.answer, ap.questionId);
						}
						activateStateById(String(XML(tp.tMeta).state.@onCompleteState));
						break;
				}
				playSound(forTextToSpeech, Translate.getSoundName(tp.name));
			}
		}
		
		private function playSound(page:String, soundName:String):void
		{
			
			if (page && _textToSpeech.apiUrl)
				_textToSpeech.speak(TextUtil.stripSurroundedBy(page, "<", ">"));
			else if (soundName)
			{
				_audioPlayer.load(soundName + soundExt);
				_audioPlayer.play();
			}
		}
		
		private function stop():void
		{
			_textToSpeech.stop();			
			_uiController.stop();
			_audioPlayer.stop();
		}
		
		// UTILITY
		
		private function getGridValues(gesture:Gesture, uip:UserInputProperties):GridValues
		{
			return MathG.gridIndexQuantizer(gesture.location.x, gesture.location.y, 
						uip.cols, uip.rows, StageRef.stage.stageWidth, StageRef.stage.stageHeight);					
		}
	}
}