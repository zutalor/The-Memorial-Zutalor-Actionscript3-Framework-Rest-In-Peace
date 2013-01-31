
package com.zutalor.view.navigator
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.application.Application;
	import com.zutalor.audio.GraphSettings;
	import com.zutalor.audio.SamplePlayer;
	import com.zutalor.audio.TextToSpeech;
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
	import flash.utils.getTimer;
	import org.gestouch.gestures.Gesture;
	import org.gestouch.gestures.TapGesture;

	
	public class ViewStateNavigator
	{		
		protected var textToSpeech:TextToSpeech;
		protected var samplePlayer:SamplePlayer;
		protected var uiController:UiControllerBase;
		protected var hkm:HotKeyManager;
		protected var gestures:gDictionary;
		protected var viewGestures:PropertyManager;
		protected var viewKeyboardInput:PropertyManager;
		protected var np:NavigatorProperties;
		
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
		
		// PROTECTED METHODS
										
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
			var up:UserInputProperties;
			var l:int;
			
			tMeta = XML(Translate.getMetaByName("settings"));
			viewGestures = new PropertyManager(UserInputProperties);
			viewGestures.parseXML(tMeta.gestures, "gesture");
			
			l = viewGestures.length;
			for (var i:int = 0; i < l; i++)
			{
				gp = viewGestures.getPropsByIndex(i);
				// TODO GEOFFgm.activateGesture(gp.type, StageRef.stage, gp.name);
			}
			
			hkm.addEventListener(HotKeyEvent.HOTKEY_PRESS, onHotKey, false, 0, true);
			viewKeyboardInput = new PropertyManager(UserInputProperties);
			viewKeyboardInput.parseXML(tMeta.keystrokes, "keystroke");
			
			l = viewKeyboardInput.length;			
			for (i = 0; i < l; i++)
			{
				up = viewKeyboardInput.getPropsByIndex(i);
				hkm.addMapping(StageRef.stage, up.name, up.name);
			}
		}
		
		protected function onHotKey(hke:HotKeyEvent):void
		{
			onUserInput(viewKeyboardInput.getPropsByName(hke.message));
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
			var tMeta:XML;
			tMeta = XML(Translate.getMetaByName(np.tip.name));
			
			switch (String(tMeta.state.@type))
			{
				case "page" :
					checkStateInput();
					break;
				case "question" :
					onAnswer();
					break;
				case "exit" :
					uiController.exit();
					break;
				default :
					break;
			}
				
			function onAnswer():void
			{
				var answer:AnswerProperties;
				var promptId:String;
				var answerText:String;
				var answerIndex:int;
				var qMark:int
				var date:Date = new Date();
			
				if (uip.action == "exit")
					uiController.exit();
				else if (uip.action == "answer")
				{
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
					
					qMark = answerText.indexOf("?");
					if (qMark != -1)
						answerText = answerText.substring(0, qMark);
						
					answer = new AnswerProperties();
					answer.answer = answerText.substr(0, 1).toUpperCase();
					answer.questionId = np.tip.name;
					answer.correctAnswer = XML(np.tip.tText)..answers.@correctAnswer;
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

					promptId = String(tMeta.state.@prompt);
					if (!promptId)
						promptId = "answer-prompt";
					
					sayText(answerText, XML(np.tip.tText)..Q[answerIndex].@sound, sayPrompt, promptId);
				}
				else
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
					case "next" :
						if (String(tMeta.state.@next) == "exit")
							uiController.exit();
						else
							activateState(tMeta.state.@next);
						break;		
					default :
						break;
				}
			}
		}
				
		protected function activateState(id:String):void
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
				uiController.getValueObject().text = getTextForDisplay(np.tip.tText);
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

							sayText(getTextForSpeech(np.tip.tText), np.tip.sound, sayPrompt, promptId);
						break;
					case "question" :
						if (!promptId)
							promptId = "question-prompt";
							
							sayText(getTextForSpeech(np.tip.tText), np.tip.sound, sayPrompt, promptId);
						break;
				}				
			}
		}
		
		protected function getTextForSpeech(text:String):String
		{
			if (text)
				return TextUtil.stripSurroundedBy(getTextForDevice(text), "<DISPLAYTEXT>", "</DISPLAYTEXT>");
			else
				return text;
		}
			
		protected function getTextForDisplay(text:String):String
		{
			if (text)
				return TextUtil.stripSurroundedBy(getTextForDevice(text), "<PHONETIC>", "</PHONETIC>");
			else
				return text;
		}
		
		protected function getTextForDevice(text:String):String
		{
			if (!text)
				return text;
			else if (AirStatus.isMobile)
				return TextUtil.stripSurroundedBy(text, "<PC>", "</PC>");
			else
				return TextUtil.stripSurroundedBy(text, "<MOBILE>", "</MOBILE>");
		}
		
		protected function submitAnswers():void
		{
			var ts:String;
			var answer:String;
			var answers:Array = [];
				
			var ap:AnswerProperties;
			for (var i:int = 0; i < np.answers.length; i++)
			{
				ap = np.answers.getByIndex(i);
				ts = TextUtil.makeCommaDelimited(ap.timestamp.split(" "));
				answer =  ap.questionId + "," + ap.answer + "," + ts
				if (ap.data)
					answer += "," + ap.data;
				
				answers.push(answer);
			}
			
			uiController[XML(np.tip.tMeta).state.@method](answers);	
			activateState(String(XML(np.tip.tMeta).state.@onCompleteState));
		}
		
		protected function sayPrompt(id:String):void
		{
			var tip:TranslateItemProperties;
			
			tip = Translate.presets.getItemPropsByName(Translate.language, id);
			
			if (tip)
			{
				uiController.getValueObject().prompt = getTextForDisplay(tip.tText);
				uiController.onModelChange();
				uiController.vc.setItemVisibility("prompt", true, 1);
				sayText(getTextForSpeech(tip.tText), tip.sound);
			}
		}
				
		protected function sayText(text:String, soundName:String, onComplete:Function = null, onCompleteArgs:* = null):void
		{	
			if (text && textToSpeech.apiUrl)
				textToSpeech.speak(text, onComplete, onCompleteArgs);
			else if (soundName)
				samplePlayer.play(np.soundPath + soundName + np.soundExt, onComplete, onCompleteArgs);
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