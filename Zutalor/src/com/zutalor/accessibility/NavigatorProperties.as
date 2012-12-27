package com.zutalor.accessibility 
{
	import com.zutalor.translate.TranslateItemProperties;
	import com.zutalor.utils.gDictionary;
	/**
	 * ...
	 * @author Geoff
	 */
	public class NavigatorProperties 
	{
		public var tip:TranslateItemProperties;
		public var curAnswerKey:String;
		public var history:Array;
		public var answers:gDictionary;
		public var dataFromSimulation:String;
		public var transitionNext:String;
		public var transitionBack:String;
		public var curTransitionType:String;
		public var promptState:String;
		public var promptStateTip:TranslateItemProperties;
		public var soundPath:String;
		public var soundExt:String;
		public var keyboardAnswers:String;
		public var inTransition:Boolean;
	}
}