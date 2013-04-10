package com.zutalor.view.navigator
{
	import com.zutalor.translate.TranslationProperties;
	import com.zutalor.utils.gDictionary;
	/**
	 * ...
	 * @author Geoff
	 */
	public class NavigatorProperties
	{
		public var id:String;
		public var curAnswerKey:String;
		public var history:Array;
		public var answers:gDictionary;
		public var data:Object;
		public var tp:TranslationProperties
		public var transitionNext:String;
		public var transitionBack:String;
		public var curTransitionType:String;
		public var promptState:String;
		public var answerStates:String;
		public var soundPath:String;
		public var soundExt:String;
		public var multipleChoiceAnswers:String;
		public var confirmationAnswers:String;
		public var inTransition:Boolean;
		public var answer:String;
		public var correctAnswer:String;
		public var answerText:String;
		public var answerIndex:int;
		public var promptId:String;
		public var nextState:String;
		public var backState:String;
		public var answerMethod:String;
			
		public function NavigatorProperties() { }
	}
}