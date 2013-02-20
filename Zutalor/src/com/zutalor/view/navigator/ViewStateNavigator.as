
package com.zutalor.view.navigator
{
	import com.greensock.TweenMax;
	import com.zutalor.air.AirStatus;
	import com.zutalor.application.Application;
	import com.zutalor.audio.GraphSettings;
	import com.zutalor.audio.SamplePlayer;
	import com.zutalor.audio.TextToSpeech;
	import com.zutalor.audio.TextToSpeechUtils;
	import com.zutalor.controllers.base.UiControllerBase;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.gesture.AppGestureEvent;
	import com.zutalor.gesture.UserInputProperties;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.text.TextUtil;
	import com.zutalor.transition.Transition;
	import com.zutalor.translate.Translate;
	import com.zutalor.translate.TranslateItemProperties;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.GridValues;
	import com.zutalor.utils.HotKeyManager;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.StageRef;
	import flash.events.KeyboardEvent;
	import org.gestouch.gestures.Gesture;
	import org.gestouch.gestures.TapGesture;

	
	public class ViewStateNavigator
	{
		protected var textToSpeech:TextToSpeech;
		protected var textToSpeechUtils:TextToSpeechUtils;
		protected var samplePlayer:SamplePlayer;
		protected var uiController:UiControllerBase;
		protected var hkm:HotKeyManager;
		protected var gestures:gDictionary;
		protected var viewGestures:PropertyManager;
		protected var multipleChoiceKeys:PropertyManager;
		protected var navigationKeys:PropertyManager;
		protected var inputText:String;
		protected var np:NavigatorProperties;
		protected var tMeta:XML;
		protected var uip:UserInputProperties;
		
		protected var allowChangingAnwers:Boolean = false;
		
		protected static const VALID_INPUT:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890()_+{}[]|\:;<,>.?/";
		
		public var OVERRIDE_SPEACH_DISABLED:Boolean = false;
		
		public function ViewStateNavigator(pUiController:UiControllerBase)
		{
			uiController = pUiController;
			init();
		}
		
		public function onUiControllerMethodCompleted(args:XMLList, data:String, id:String):void
		{
			np.data = data;
			np.id = id;
			activateState(args.@onCompleteState);
		}
		
		public function activateState(id:String):void
		{
			var t:Transition;

			if (!np.inTransition)
			{
				np.inTransition = true;
				stop();
				np.tip = Translate.presets.getItemPropsByName(Translate.language, id);
				uiController.getValueObject().prompt = "";
				if (!np.tip)
				{
					trace("State not found: " + id);
					return;
				}
				np.history.push(np.tip.name);
				uiController.getValueObject().text = textToSpeechUtils.getTextForDisplay(np.tip.tText);
				uiController.onModelChange();
				
				if (np.curTransitionType)
				{
					t = new Transition();
					t.simpleRender(uiController.vc.container,np.curTransitionType, "in", onTransitionComplete);
				}
				else
				{
					onTransitionComplete();
				}
			}
		
			function onTransitionComplete():void
			{
				var promptId:String;
				
				np.inTransition = false;
				promptId = String(XML(np.tip.tMeta).state.@prompt);
				
				switch (String(XML(np.tip.tMeta).state.@type))
				{
					case "uiControllerMethod" :
						np.data = "";
						uiController[XML(np.tip.tMeta).state.@method](XML(np.tip.tMeta).state);
						break;
					case "submitAnswers" :
						submitAnswers();
						break;
					case "page" :
						if (!promptId)
							promptId = "page-prompt";
							speak(textToSpeechUtils.getTextForSpeech(np.tip.tText), np.tip.sound, sayPrompt, promptId);
						break;
					case "multipleChoice" :
						if (!promptId)
							promptId = "mulipleChoicePrompt";
						
						speak(textToSpeechUtils.getTextForSpeech(np.tip.tText), np.tip.sound, sayPrompt, promptId);
						KeyListeners(true, multipleChoiceKeys);
						break;
					case "textInput" :
						if (!promptId)
							promptId = "textInputPrompt";
						
						inputText = "";
						speak(textToSpeechUtils.getTextForSpeech(np.tip.tText), np.tip.sound, sayPrompt, promptId);
						KeyListeners(false, multipleChoiceKeys);
						StageRef.stage.addEventListener(KeyboardEvent.KEY_UP, captureTextInput, false,0, true);
						break;
						
				}
			}
		}

		
		// PROTECTED METHODS
		
		protected function KeyListeners(add:Boolean, propertyManager:PropertyManager):void
		{
			var l:int;
			var func:Function;
			var userInputProperties:UserInputProperties;
				
			l = propertyManager.length;
			for (var i:int = 0; i < l; i++)
			{
				userInputProperties = propertyManager.getPropsByIndex(i);
				if (add)
					hkm.addMapping(StageRef.stage, userInputProperties.name, userInputProperties.name);
				else
					hkm.removeMapping(StageRef.stage, userInputProperties.name);
			}
		}
										
		protected function init():void
		{
			var l:int;
			var gs:GraphSettings;
			var tMeta:XML;
			var textToSpeechUrl:String;
		
			np = new NavigatorProperties();
			np.answers = new gDictionary();
			np.history = [];
			hkm = HotKeyManager.gi();
			//gm.addEventListener(AppGestureEvent.RECOGNIZED, onGesture);
			samplePlayer = new SamplePlayer();
			
			if (AirStatus.isMobile)
				textToSpeechUrl = Application.settings.textToSpeechApiUrlMobile;
			else
				textToSpeechUrl = Application.settings.textToSpeechApiUrlPC;
				
			textToSpeech = new TextToSpeech(textToSpeechUrl);
			textToSpeechUtils = new TextToSpeechUtils();
			textToSpeech.enabled = Application.settings.enableTextToSpeech;
			tMeta = XML(Translate.getMetaByName("settings"));
			np.transitionNext = tMeta.settings.@transitionNext;
			np.transitionBack = tMeta.settings.@transitionBack;
			np.promptState = tMeta.settings.@promptState;
			np.soundPath = tMeta.settings.@soundPath;
			np.soundExt = tMeta.settings.@soundExt;
			np.keyboardAnswers = tMeta.settings.@keyboardAnswers;
			
			initUserInput();
			activateState(tMeta.settings.@firstPage);
		}
		
		protected function initUserInput():void
		{
			var tMeta:XML;
			var gp:UserInputProperties;
			var userInputProperties:UserInputProperties;
			var l:int;
			
			hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey, false, 0, true);
			
			tMeta = XML(Translate.getMetaByName("settings"));
			
			viewGestures = new PropertyManager(UserInputProperties);
			viewGestures.parseXML(tMeta.gestures, "gesture");
			
		/*	l = viewGestures.length;
			for (var i:int = 0; i < l; i++)
			{
				gp = viewGestures.getPropsByIndex(i);
				// TODO GEOFFgm.activateGesture(gp.type, StageRef.stage, gp.name);
			}*/
			
			
			multipleChoiceKeys = new PropertyManager(UserInputProperties);
			multipleChoiceKeys.parseXML(tMeta.keystrokes, "keystroke");
			navigationKeys = new PropertyManager(UserInputProperties);
			navigationKeys.parseXML(tMeta.navigation, "keystroke");
			
			KeyListeners(true, navigationKeys);
		}
		
		protected function onHotKey(hke:HotKeyEvent):void
		{
			var uip:UserInputProperties;
			
			uip = navigationKeys.getPropsByName(hke.message);
			
			if (uip)
				onUserInput(uip);
			else
			{
				uip = multipleChoiceKeys.getChildIndexByName(hke.message);
				if (uip)
					onUserInput(uip);
			}
		}
		
		protected function onGesture(age:AppGestureEvent):void
		{
			/*
			var uip:UserInputProperties;
			
			uip = viewGestures.getPropsByName(age.name);
		
			if (age.gesture is SwipeGesture)
			{
				if (SwipeGesture(age.gesture).offsetX > 1)
					uip.action = uip.actionRight;
				else if (SwipeGesture(age.gesture).offsetY < 1)
					uip.action = uip.actionLeft;
			}
			if (uip)
				onUserInput(uip, age.gesture);
				*/
		}
		
		protected function onUserInput(uip:UserInputProperties, gesture:Gesture = null):void
		{
			tMeta = XML(Translate.getMetaByName(np.tip.name));
			
			switch (String(tMeta.state.@type))
			{
				case "page" :
					checkStateInput();
					break;
				case "multipleChoice" :
					onMultipleChoiceAnswer();
					break;
				case "textInput" :
					onTextInput(uip);
					break;
				case "exit" :
					uiController.exit();
					break;
				default :
					break;
			}
				
			function onMultipleChoiceAnswer():void
			{
				var promptId:String;
				var answerText:String;
				var answerIndex:int;
				
				if (uip.action == "exit")
					uiController.exit();
				else if (uip.action != "answer")
					checkForValidAnswer();
				else {
					if (uip.type == Plugins.getClassName(TapGesture))
						answerIndex = getGridValues(gesture, uip).index;
					else
						answerIndex = np.keyboardAnswers.indexOf(uip.name.toLowerCase());

					answerText = XML(np.tip.tText)..Q[answerIndex];
					
					if (!answerText)
					{
						activateState(np.tip.name);
						return;
					}
					
					saveAnswer(answerText.substr(0, 1).toUpperCase(), XML(np.tip.tText)..answers.@correctAnswer);
					
					if (allowChangingAnwers)
					{
						promptId = String(tMeta.state.@prompt);
						if (!promptId)
							promptId = "answer-prompt";
						
						speak(answerText, XML(np.tip.tText)..Q[answerIndex].@sound, sayPrompt, promptId);
					}
					else
						checkForValidAnswer();
				}
				
				function checkForValidAnswer():void
				{
					if (np.answers.getByKey(np.curAnswerKey))
					{
						checkStateInput(uip);
						np.curAnswerKey = null;
					}
					else
						activateState(np.tip.name);
				}
			}
			
			function checkStateInput():void
			{
				np.curTransitionType = np.transitionNext;
				switch (uip.action)
				{
					case "back" :
						if (String(tMeta.state.@back))
						{
							np.curTransitionType = np.transitionBack;
							activateState(tMeta.state.@back);
						}
						else
						{
							np.curTransitionType = null;
							activateState(np.tip.name);
						}
						break;
					default :
						if (String(tMeta.state.@next) == "exit")
							uiController.exit();
						else
							activateState(tMeta.state.@next);
						break;
				}
			}
			
			function saveAnswer(answerText:String, correctAnswer:String):void
			{
				var answer:AnswerProperties;
				var date:Date;
			
				date = new Date();
				answer = new AnswerProperties();
				
				answer.answer = answerText;
				answer.questionId = np.tip.name;
				answer.correctAnswer = correctAnswer;
				answer.timestamp = date.toString();
				
				if (np.data)
				{
					answer.questionId = np.tip.name + "-" + np.id;
					answer.data = np.data;
				}
				else
				{
					answer.questionId = np.tip.name;
					answer.data = "";
				}
				
				np.curAnswerKey = answer.questionId;
				np.answers.insert(np.curAnswerKey, answer);
			}
		}
		
		protected function onTextInput(uip:UserInputProperties):void
		{
			var l:int;
			var key:String;
			
			if (uip.action == "complete")
				trace(inputText);
			else if (uip.action == "backspace")
			{
				key = inputText.substr(inputText.length - 1, 1).toLowerCase();
				speak(key, key);
				//inputText = inputText.substr(0, inputText.length - 1);
				//uiController.onModelChange();
			}
			else if (uip.action == "space")
			{
				if (inputText.charAt(inputText.length -1) != " ")
					inputText += " ";

				
				l = inputText.length - 2;
				for (var i:int = l; i > 0; i--)
				{
					if (inputText.charAt(i-1) == " ")
						break;
				}
				key = inputText.substr(i).toLowerCase();
				speak(key, key, null, null, OVERRIDE_SPEACH_DISABLED);
			}
			//uiController.getValueObject().inputText = "<P>" + inputText + "</P>";
			//uiController.onModelChange("inputText");
			
		}
		
		protected function captureTextInput(ke:KeyboardEvent):void
		{
			var key:String;
			
			key = String.fromCharCode(ke.charCode);
			if (VALID_INPUT.indexOf(key.toUpperCase()) != -1)
			{
				speak(key, key);
				inputText += key;
				//uiController.getValueObject().inputText = "<P>" + inputText + "</P>";
				//uiController.onModelChange("inputText");
			}
			else
				hkm.clearKeys();
		}
		
		protected function submitAnswers():void
		{
			var timeStamp:String;
			var answer:String;
			var answers:Array = [];
				
			var ap:AnswerProperties;
			for (var i:int = 0; i < np.answers.length; i++)
			{
				ap = np.answers.getByIndex(i);
				timeStamp = TextUtil.makeCommaDelimited(ap.timestamp.split(" "));
				answer =  ap.questionId + "," + ap.answer + "," + timeStamp;
				if (ap.data)
					answer += "," + ap.data;
				
				answers.push(answer);
			}
			
			uiController[XML(np.tip.tMeta).state.@method](answers,
							String(XML(np.tip.tMeta).state.@onCompleteState));
		}
		
		protected function speak(text:String, soundName:String, onComplete:Function = null, onCompleteArgs:* = null, overRideDisableSpeech:Boolean = false):void
		{
			textToSpeech.sayText(text, np.soundPath + soundName + np.soundExt, onComplete, onCompleteArgs, overRideDisableSpeech);
		}
		
		protected function sayPrompt(id:String):void
		{
			var tip:TranslateItemProperties;
			
			tip = Translate.presets.getItemPropsByName(Translate.language, id);
			
			if (tip)
			{
				uiController.getValueObject().prompt = textToSpeechUtils.getTextForDisplay(tip.tText);
				uiController.onModelChange();
				uiController.vc.getItemByName("prompt").alpha = 0;
				TweenMax.to(uiController.vc.getItemByName("prompt"), .5, { alpha:1 } );
				speak(textToSpeechUtils.getTextForSpeech(tip.tText), tip.sound);
			}
		}
		
		protected function stop():void
		{
			textToSpeech.stop();
			uiController.stop();
			samplePlayer.stop();
		}
		
		// UTILITY
		
		protected function getGridValues(gesture:Gesture, uip:UserInputProperties):GridValues
		{
			return MathG.gridIndexQuantizer(gesture.location.x, gesture.location.y,
						uip.cols, uip.rows, StageRef.stage.stageWidth, StageRef.stage.stageHeight);
		}
	}
}