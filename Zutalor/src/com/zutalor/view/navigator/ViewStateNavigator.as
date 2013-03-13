
package com.zutalor.view.navigator
{
	import com.greensock.TweenMax;
	import com.hurlant.util.der.ObjectIdentifier;
	import com.zutalor.air.AirStatus;
	import com.zutalor.application.Application;
	import com.zutalor.audio.GraphSettings;
	import com.zutalor.audio.SamplePlayer;
	import com.zutalor.controllers.base.UiControllerBase;
	import com.zutalor.events.HotKeyEvent;
	import com.zutalor.gesture.UserInputProperties;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.text.StringUtils;
	import com.zutalor.text.TextUtil;
	import com.zutalor.transition.BitMapSlide;
	import com.zutalor.transition.Transition;
	import com.zutalor.translate.Translate;
	import com.zutalor.translate.TranslationProperties;
	import com.zutalor.utils.EmbeddedResources;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.HotKeyManager;
	import com.zutalor.utils.Logger;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.StageRef;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import Zutalor.src.com.zutalor.textToSpeech.TextToSpeech;
	import Zutalor.src.com.zutalor.textToSpeech.TextToSpeechUtils;
	
	public class ViewStateNavigator
	{
		protected var textToSpeech:TextToSpeech;
		protected var samplePlayer:SamplePlayer;
		protected var textToSpeechUtils:TextToSpeechUtils;
		protected var uiController:UiControllerBase;
		protected var hkm:HotKeyManager;
		protected var hotKeys:PropertyManager;
		protected var inputText:String;
		protected var np:NavigatorProperties;
		protected var tMeta:XML;
		protected var uip:UserInputProperties;
		protected var currentStateType:String;
		protected var bitMapSlide:BitMapSlide;
		protected var transition:Transition
		
		protected var wordHasBeenSaid:Boolean;
		protected var keyPressInvalidated:Boolean;
		
		protected var allowAnswerChanging:Boolean = true;
		protected var promptId:String;
		protected var promptCancelled:Boolean;

		protected var KEYSTROKE_DELAY_BEFORE_SAYING_WORD:int = 1500;
		protected var DELAY_FROM_LAST_KEYSTROKE_BEFORE_SAYING_PROMPT:int = 5000;
		protected var PROMPT_DELAY_ON_ANSWER:int = 2000;
		
		public static const TAB:int = 9;
		
		protected static const PUNCTUATION:Array = ["'", "*", ";", ":", "-", "}", "{", "+", "_", ")",
													"(", "?", ".", ",", '"', "[" , "]", "~", "`",
													"!", "@", "#", "$", "%", "^", "=", "<", ">", "/", "\\", "|", "&" , " "];
		protected static const PUNCTUATION_NAMES:Array = [ "apostrophe", "star", "semicolon", "colon", "dash", "rightbrace", "leftbrace",
					"plus", "underscore", "rightparen", "leftparen", "questionmark", "period", "comma", "quote",
					"leftbracket", "rightbracket", "tilda", "accent", "exclamation", "at", "pound",
					"dollar", "percent", "carot", "equals", "less", "greater", "backslash", "forwardslash", "verticalline", "ampersand", "space" ];
		
		protected static const VALID_INPUT:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890~`!@#$%^&*()_+-={}[]:;\\',<>/|" + '"';
		
		public function ViewStateNavigator(pUiController:UiControllerBase)
		{
			uiController = pUiController;
			init();
		}
		
		public function speak(text:String, soundName:String, onComplete:Function = null,
													onCompleteArgs:* = null):void
		{
			if (soundName)
				soundName = np.soundPath + soundName.toLowerCase() + np.soundExt;
				
			textToSpeech.sayText(text, soundName, onComplete, onCompleteArgs);
		}

		public function onUiControllerMethodCompleted(args:XMLList, data:Object, id:String):void
		{
			np.data = data;
			np.id = id;
			activateState(args.@onCompleteState);
		}
		
		public function playEmbedded(audioClassName:String, onComplete:Function = null):void
		{
			textToSpeech.volume = 0;
			samplePlayer.play(null, EmbeddedResources.getClass(audioClassName), resetVolume );
			
			function resetVolume():void
			{
				textToSpeech.volume = 1;
				if (onComplete != null)
					onComplete();
			}
		}
		
		public function activateState(id:String):void
		{
			var tempTp:TranslationProperties;
			
			textToSpeech.stop();
			
			if (!np.inTransition)
			{
				np.inTransition = true;
				stop();
				tempTp = Translate.presets.getPropsByName(id);
				
				if (!tempTp)
				{
					trace("State not found: " + id);
					np.inTransition = false;
					return;
				}
			
				np.tp = tempTp;
				np.history.push(np.tp.name);
				uiController.getValueObject().text = textToSpeechUtils.getTextForDisplay(np.tp.tText);
				uiController.getValueObject().prompt = "";
				uiController.getValueObject().inputText = inputText = "";
				
				if (np.curTransitionType)
				{
					
					bitMapSlide.out(uiController.vc.container, np.curTransitionType);
					transition.simpleRender(uiController.vc.container, np.curTransitionType, "in", initializeState);
					uiController.onModelChange();
				}
				else
				{
					uiController.onModelChange();
					initializeState();
				}
			}
		}
		
		public function deactivate():void
		{
			StageRef.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			StageRef.stage.removeEventListener(KeyboardEvent.KEY_UP, captureTextInput);
			KeyListeners(false);
		}
		
		protected function initializeState():void
		{
			np.inTransition = false;
			promptId = String(XML(np.tp.tMeta).state.@prompt);
			currentStateType = String(XML(np.tp.tMeta).state.@type);
			np.answerStates = String(XML(np.tp.tMeta).state.@answerStates);
			np.nextState = String(XML(np.tp.tMeta).state.@next);
			np.backState = String(XML(np.tp.tMeta).state.@back);
			
			if (String(XML(np.tp.tMeta).state.@includeUiControllerData) != "true")
				np.data = null;

			MasterClock.unRegisterCallback(checkForKeystrokePause);
			MasterClock.unRegisterCallback(checkForUserDelay);
			StageRef.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);

			if (currentStateType == "uiControllerMethod")
			{
				stop();
				np.data = "";
				uiController[XML(np.tp.tMeta).state.@method](XML(np.tp.tMeta).state);
			}
			else
			{
				if (currentStateType == "textInput")
				{
					MasterClock.registerCallback(checkForKeystrokePause, true, KEYSTROKE_DELAY_BEFORE_SAYING_WORD);
					StageRef.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
					StageRef.stage.addEventListener(KeyboardEvent.KEY_UP, captureTextInput, false, 0, true);
				}
				//else if (currentStateType == "page")
				//	uiController.logEvent("page: " + np.tp.name);
				
				
				if (!promptId)
						promptId = currentStateType;
				
				sayText();
				checkForMethodCall();
			}
		}
		
		protected function checkForMethodCall():void
		{
			var method:String;
			var params:String;
			
			method = String(XML(np.tp.tMeta).state.@method);
			params = String(XML(np.tp.tMeta).state.@methodParams);
			
			if (method)
			{
				if (params)
					uiController[method](params);
				else
					uiController[method]();
			}
		}
		
		// PROTECTED METHODS
		
		protected function KeyListeners(add:Boolean):void
		{
			var l:int;
			var userInputProperties:UserInputProperties;
				
			l = hotKeys.length;
			for (var i:int = 0; i < l; i++)
			{
				userInputProperties = hotKeys.getPropsByIndex(i);
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
			bitMapSlide = new BitMapSlide();
			transition = new Transition();
		
			Logger.eTrace("Agent " + Application.settings.agent);
			if (StringUtils.find("MSIE", Capabilities.os) && Capabilities.playerType != "Desktop")
				textToSpeechUrl = Application.settings.textToSpeechProxyApi;
			else
				textToSpeechUrl = Application.settings.textToSpeechDirectApi;
				
			textToSpeech = new TextToSpeech(textToSpeechUrl);
			textToSpeech.tempo = 1.2;
			textToSpeechUtils = new TextToSpeechUtils();
			samplePlayer = new SamplePlayer();
			textToSpeech.enabled = Application.settings.enableTextToSpeech;
			
			tMeta = XML(Translate.getMetaByName("settings"));
			np.transitionNext = tMeta.settings.@transitionNext;
			np.transitionBack = tMeta.settings.@transitionBack;
			np.promptState = tMeta.settings.@promptState;
			np.soundPath = tMeta.settings.@soundPath;
			np.soundExt = tMeta.settings.@soundExt;
			np.multipleChoiceAnswers = tMeta.settings.@multipleChoiceAnswers;
			np.confirmationAnswers = tMeta.settings.@confirmationAnswers;
			np.answerMethod = tMeta.settings.@answerMethod;
			initUserInput();
			trace(tMeta.settings.@firstState);
			if (String(tMeta.settings.@firstState))
				activateState(tMeta.settings.@firstState);
		}
		
		protected function initUserInput():void
		{
			var tMeta:XML;
			var gp:UserInputProperties;
			var userInputProperties:UserInputProperties;
			var l:int;
			
			hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey, false, 0, true);
			tMeta = XML(Translate.getMetaByName("settings"));
			hotKeys = new PropertyManager(UserInputProperties);
			hotKeys.ignoreCaseInKey = false;
			hotKeys.parseXML(tMeta.hotkeys, "keystroke");
			KeyListeners(true);
		}
		
		protected function onKeyUp(ke:KeyboardEvent):void
		{
			if (!np.inTransition
					&& hkm.keyInvalidated
					&& currentStateType != "uiControllerMethod"
					&& ke.charCode && ke.charCode != TAB)
						playEmbedded("Unrecognized");
		}
		
		protected function onHotKey(hke:HotKeyEvent):void
		{
			var uip:UserInputProperties;

			hkm.clearKeys();
			
			if (np.inTransition)
				return;
			
			uip = hotKeys.getPropsByName(hke.message);
			
			if (currentStateType != "uiControllerMethod"
									&& (uip.activeForStateType == "all" || uip.activeForStateType == currentStateType))
				onUserInput(uip);
			else
				trace(currentStateType);
		}
		
		protected function checkForKeystrokePause():void
		{
			if (!wordHasBeenSaid)
				sayLastWord();
		}
		
		protected function checkForUserDelay():void
		{
			stopUserDelayTimer();
			sayPrompt(promptId, restartUserDelayTimer);
		}
		
		protected function stopUserDelayTimer():void
		{
			MasterClock.stop(checkForUserDelay);
		}
		
		protected function restartUserDelayTimer():void
		{
			MasterClock.start(checkForUserDelay);
		}
		
		protected function onUserInput(uip:UserInputProperties):void
		{
			if (!np.tp)
				return;
			else
				tMeta = XML(Translate.getMetaByName(np.tp.name));
			
			switch (uip.action)
			{
				case "exit" :
					uiController.exit();
					break;
				case "goodbye" :
					activateState("goodbye");
					break;
				case "back" :
					activateNextState(uip);
					break;
				case "next" :
					validateInput(uip);
					break;
				case "faster" :
					if (textToSpeech.paused)
						break;
					if (textToSpeech.tempo < 2.7)
						textToSpeech.tempo += .1;
					uiController.logEvent("Tempo Change: " + textToSpeech.tempo.toPrecision(2));
					break;
				case "slower" :
					if (textToSpeech.paused)
						break;
					if (textToSpeech.tempo > .3)
						textToSpeech.tempo -= .1;
					uiController.logEvent("Tempo Change: " + textToSpeech.tempo.toPrecision(2));
					break;
				case "rewind" :
					textToSpeech.rewind();
					break;
				case "pause" :
					textToSpeech.pause();
					break;
				default :
					onAnswer();
					break;
			}
			
			function onAnswer():void
			{
				switch (currentStateType)
				{
					case "multipleChoice" :
					case "confirmation" :
						onMultipleChoice(uip, currentStateType);
						break;
					case "textInput" :
						onTextInput(uip);
						break;
					default :
						break;
				}
			}
		}
		
		protected function validateInput(uip:UserInputProperties):void
		{
			var asa:Array;
			var l:int;
			
			if (currentStateType == "page")
			{
				activateNextState(uip);
				return;
			}
			
			if (np.answerStates)
			{
				asa = np.answerStates.split(",");
				if (np.answerIndex < asa.length && asa[np.answerIndex])
					np.nextState = asa[np.answerIndex];
			}
			
			if (np.answer)
			{
				saveAnswer(np);
				np.answer = null;
				activateNextState(uip);
			}
			else
				speak("Please answer.", "pleaseanswer");
		}
		
		protected function onMultipleChoice(uip:UserInputProperties, stateType:String):void
		{
			var promptDelay:int;
			
			if (stateType == "confirmation")
				np.answerIndex = np.confirmationAnswers.indexOf(uip.name.toLowerCase());
			else
				np.answerIndex = np.multipleChoiceAnswers.indexOf(uip.name.toLowerCase());

			if (XML(np.tp.tText)..Q[np.answerIndex] == undefined)
				playEmbedded("Unrecognized");
			else
			{
				np.answerText = String(XML(np.tp.tText)..Q[np.answerIndex]);
				np.correctAnswer = XML(np.tp.tText)..answers.@correctAnswer;
				np.answer = np.answerText.substr(0, 1).toUpperCase();
				
				if (XML(np.tp.tMeta).state.@noPromptDelay != "true")
					promptDelay = PROMPT_DELAY_ON_ANSWER;
				
				if (promptId != "none")
					speak(np.answerText, XML(np.tp.tText)..Q[np.answerIndex].@sound, sayPrompt, "onAnswered");
				else
					speak(np.answerText, XML(np.tp.tText)..Q[np.answerIndex].@sound);
			}
		}
		
		protected function activateNextState(uip:UserInputProperties):void
		{
			np.curTransitionType = np.transitionNext;
			switch (uip.action)
			{
				case "back" :
					if (np.backState)
					{
						np.curTransitionType = np.transitionBack;
						activateState(np.backState);
					}
					else
					{
						np.curTransitionType = null;
						activateState(np.tp.name);
					}
					break;
				default :
					if (np.nextState == "exit")
						uiController.exit();
					else
						activateState(np.nextState);
					break;
			}
		}
		
		protected function saveAnswer(np:NavigatorProperties):void
		{
			var answer:AnswerProperties;
			var date:Date;
		
			date = new Date();
			answer = new AnswerProperties();
			
			if (np.data)
			{
				answer.dataId = np.id;
				answer.data = np.data;
			}
			else
			{
				answer.questionId = np.tp.name;
				answer.data = "";
			}
			
			answer.answer = np.answer;
			answer.questionId = np.tp.name;
			
			answer.date = date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear();
			answer.time = date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
			answer.UTCTimezoneOffset = String(date.getTimezoneOffset() / 60 * -1);
			answer.questionId = np.tp.name;
			
			Object(uiController).getCorrectAnswer(answer, answer.answer, returnAnswerTo);

			np.curAnswerKey = answer.questionId;
			np.answers.insert(np.curAnswerKey, answer);

			function returnAnswerTo():void
			{
				submitCurrentAnswer(answer);
			}
		}
		
		protected function onTextInput(uip:UserInputProperties):void
		{
			var key:String;
			
			key = inputText.substr(inputText.length - 1, 1).toLowerCase();
			
			switch (uip.action)
			{
				case "back" :
					sayText();
					break;
				case "backspace" :
					speakKey(key);
					wordHasBeenSaid = false;
					inputText = inputText.substr(0, inputText.length - 1);
					break;
				case "left" :
					trace("left");
					break;
				case "right" :
					trace("right");
					break;
				case "period" :
					inputText += ".";
					speakKey(".", sayLastWord);
					break;
				case "questionMark" :
					inputText += "?";
					speakKey("?", sayLastWord);
					break;
				case "space" :
					inputText += " ";
					speakKey(" ", sayLastWord);
					break;
				case "enter" :
					sayAnswer();
					break;
			}
			updateInputTextView();
		}
		
		protected function updateInputTextView():void
		{
			uiController.getValueObject().inputText =  "<P>" + textToSpeechUtils.getTextForDisplay(inputText) + "</P>";
			uiController.onModelChange("inputText");
			np.answer = np.answerText = inputText;
			np.correctAnswer = null;
		}
		
		protected function sayText():void
		{
			speak(textToSpeechUtils.getTextForSpeech(np.tp.tText), np.tp.sound, sayPrompt, promptId);
		}
		
		protected function sayAnswer():void
		{
			stopUserDelayTimer();
			speak(inputText, null, restartUserDelayTimer);
		}
		
		protected function sayLastWord():void
		{
			var l:int;
			var word:String;
			
			if (wordHasBeenSaid)
				return;

			if (inputText && inputText.length)
				wordHasBeenSaid = true;
			else
				return;
			
			l = inputText.length - 2;
			for (var i:int = l; i > 0; i--)
			{
				if (inputText.charAt(i-1) == " ")
					break;
			}
			word = inputText.substr(i).toLowerCase();
			speak(word, word, checkEndOfSentence);
		}
		
		protected function checkEndOfSentence():void
		{
			var lastChar:String;
			
			lastChar = inputText.charAt(inputText.length -1);
			if (lastChar == "." || lastChar == "?" || lastChar == "!")
				speakKey(lastChar);
		}
		
		protected function captureTextInput(ke:KeyboardEvent):void
		{
			var key:String;
			
			key = String.fromCharCode(ke.charCode);
			if (VALID_INPUT.indexOf(key.toUpperCase()) != -1)
			{
				MasterClock.resetAndStart(checkForKeystrokePause);
				MasterClock.resetAndStart(checkForUserDelay);
				MasterClock.registerCallback(checkForUserDelay, true, DELAY_FROM_LAST_KEYSTROKE_BEFORE_SAYING_PROMPT);
				wordHasBeenSaid = false;
				speakKey(key);
				inputText += key;
				updateInputTextView();
			}
			else
				hkm.clearKeys();
		}
		
		protected function speakKey(key:String, onComplete:Function = null, onCompleteArgs:*=null):void
		{
			var indx:int;
						
			indx = PUNCTUATION.indexOf(key);
			
			if (indx != -1)
			{
				key = PUNCTUATION_NAMES[indx];
				speak(key, key, onComplete, onCompleteArgs);
			}
			else
				speak(key, key, onComplete, onCompleteArgs);
		}
		
		protected function submitCurrentAnswer(answer:AnswerProperties):void
		{
			uiController[np.answerMethod](answer,
							String(XML(np.tp.tMeta).state.@onCompleteState));
		}
		
		protected function sayPrompt(id:String, onComplete:Function = null, onCompleteArgs:* = null):void
		{
			var tp:TranslationProperties;
			tp = Translate.presets.getPropsByName(id);
			if (tp)
			{
				uiController.getValueObject().prompt = textToSpeechUtils.getTextForDisplay(tp.tText);
				uiController.onModelChange("prompt");
				uiController.vc.getItemByName("prompt").alpha = 0;
				TweenMax.to(uiController.vc.getItemByName("prompt"), .5, { alpha:1 } );
				speak(textToSpeechUtils.getTextForSpeech(tp.tText), tp.sound, onComplete, onCompleteArgs);
			}
		}
				// UTILITY
		
		protected function stop():void
		{
			textToSpeech.stop();
			uiController.stop();
			samplePlayer.stop();
		}
	}
}