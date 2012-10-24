package com.swfjunkie.accessibility
{
	import com.swfjunkie.accessibility.impl.CustomAccImpl;
	
	import flash.accessibility.Accessibility;
	import flash.accessibility.AccessibilityProperties;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * A simple to use Accessibility Helper
	 * @author Sandro Ducceschi [swfjunkie.com, Switzerland]
	 */
	
	public class JAcc
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		private static var lastString:String;
        private static var accTimer:Timer;
        private static var onceTimer:Timer;
        private static var accCount:Number;
        private static var accIndex:Number;
        private static var accLength:Number;
        private static var accCurrentSubs:XMLList;
        
        private static var isAudible:Boolean = true;
        private static var isSubtitled:Boolean = false;
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
        /** The Custom accessibility implementation assigned to AccLame */ 
        public static var accImplementation:CustomAccImpl
        
        /** TextField for Braille Display output*/
        public static var brailleTextComponent:Object;
        
        /** TextField for Subtitling */
        public static var subtitleTextComponent:Object
        
        private static var _queueStarted:Boolean = false;
        /** Boolean indicating if there is a text queue running or not */
        public static function get queueStarted():Boolean
        {
            return _queueStarted;
        }
        /** Default removal delay for subtitles that are not part of a queue (in Milliseconds) */
        public static var subtitleRemovalDelay:int = 0;
		//--------------------------------------------------------------------------
		//
		//  API
		//
		//--------------------------------------------------------------------------
		
        /**
         * Will speak/write the passed text through assitive technologies/textfields
         * @param say                   The text you want to be spoken/written
         * @param subtitled             (Optional) If subtitles should be shown (only works if there is a subtitle textfield)
         * @param overwriteLastString   (Optional) If the last text should be saved for re-use or not
         */  
		public static function say(text:String, subtitled:Boolean = false, overwriteLastString:Boolean = true):void
		{
			var accProperties:AccessibilityProperties;
			var text:String = text.replace(/<[^<]+?>/g, " ");
			var fillText:String = "";
			
			if (accImplementation && accImplementation.listener)
			{
				if (accImplementation.listener.accessibilityProperties)
					accProperties = accImplementation.listener.accessibilityProperties;
				else
					accProperties = new AccessibilityProperties();
				
                if (lastString && text.length <= lastString.length)
                {
                    var difference:int = lastString.length - text.length;
                    for (var i:int = 0; i <= difference; i++)
                        fillText += " ";
                    text += fillText;
                }
                
				if (brailleTextComponent && brailleTextComponent.hasOwnProperty("text"))
                    brailleTextComponent.text = text;
                
				accProperties.name = text.toLowerCase();
				accProperties.silent = false;
				accProperties.noAutoLabeling = true;
				accProperties.forceSimple = true;
                accImplementation.listener.accessibilityProperties = accProperties;
				
				if (Accessibility.active)
				{
					Accessibility.updateProperties();
					Accessibility.sendEvent(accImplementation.listener, 0, 0x8005, true);
				}
                
				if (overwriteLastString)
					lastString = text;
                
                if (subtitled && subtitleTextComponent)
                {
                    if (subtitleRemovalDelay > 0)
                    {
                        if (!onceTimer)
                        {
                            onceTimer = new Timer(subtitleRemovalDelay, 1);
                            onceTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleOnceTimer);
                        }
                        if (onceTimer && onceTimer.running)
                            onceTimer.stop();
                        onceTimer.delay = subtitleRemovalDelay;
                        onceTimer.start();
                    }
                    updateSubtitles(text);
                }
			}
		}
		
		/**
         * Repeats the last text (if available)
         * @param subtitled  (Optional) If subtitles should be shown (only works if there is a subtitle textfield)
         */ 
		public static function repeatLastSay(subtitled:Boolean = false):void
		{
			if (lastString)
				say(lastString);
		}
        
        /**
         * Plays a queue of text (ideal for subtitling)
         * @param content       An XML of <text> nodes. See examples for a usage example.
         * @param isAudible     Whether the text should be spoken if there is assistive technology available
         * @param isSubtitled   Whether the text should be shown as subtitles (only works if there is a subtitle textfield)
         */ 
        public static function queuePlay(content:XMLList, isAudible:Boolean = true, isSubtitled:Boolean = false):void
        {
            JAcc.isAudible = isAudible;
            JAcc.isSubtitled = isSubtitled;
            accTimer = new Timer(100, 0);
            _queueStarted = true;
            accCount = -100;
            accIndex = 0;
            accCurrentSubs = content;
            accLength = accCurrentSubs.text.length();
            accTimer.addEventListener(TimerEvent.TIMER, handleAccTimerEvent);
            handleAccTimerEvent();
            accTimer.start();
        }
        
        /**
         * Stops a previously started text queue
         */ 
        public static function queueStop():void
        {
            if (accTimer)
            {
                accTimer.stop();
                _queueStarted = false;
                accTimer.removeEventListener(TimerEvent.TIMER, handleAccTimerEvent);
                accTimer = null;
                updateSubtitles();
            }
        }
        
        /**
         * Plays/Pauses a active text queue
         */ 
        public static function queuePause():void
        {
            if (accTimer && accTimer.running)
                accTimer.stop();
            else if (accTimer && !accTimer.running)
                accTimer.start();
        }
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
        /** @private */
        private static function updateSubtitles(text:String = null):void
        {
            if (subtitleTextComponent && subtitleTextComponent.hasOwnProperty("text"))
            {
                if (text)
                    subtitleTextComponent.text = text.replace(/\<br\/\>/g, "\n");
                else
                    subtitleTextComponent.text = "";
            }
        }
        
        /** @private */
        private static function returnTimeInMS(timeString:String):Number
        {
            var timeArr:Array = timeString.split(":");
            var hour:Number = parseFloat(timeArr[0])*60*60;
            var minutes:Number = parseFloat(timeArr[1])*60;
            var seconds:Number = parseFloat(timeArr[2]);
            return  ((hour + minutes + seconds) * 1000) + parseFloat(timeArr[3]); 
        }
		//--------------------------------------------------------------------------
		//
		//  Eventhandling
		//
		//--------------------------------------------------------------------------
        /** @private */
        private static function handleAccTimerEvent(event:TimerEvent = null):void
        {
            accCount += 100;
            if (accIndex < accLength)
            {
                var element:XML = accCurrentSubs.text[accIndex];
                var startTime:Number = returnTimeInMS(element.@start);
                var endTime:Number = returnTimeInMS(element.@end);
                if (accCount == endTime)
                {
                    if (accIndex + 1 < accLength)
                    {
                        if (isSubtitled)
                            updateSubtitles();
                        accIndex++;
                        element = accCurrentSubs.text[accIndex];
                        startTime = returnTimeInMS(element.@start);
                    }
                    else
                    {
                        queueStop();
                    }
                }
                
                if (accCount == startTime)
                {
                    if (isAudible)
                        say(element);
                    if (isSubtitled)
                        updateSubtitles(element);
                }
            }
        }
        
        /** @private */
        private static function handleOnceTimer(event:TimerEvent):void
        {
            onceTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, handleOnceTimer);
            onceTimer.stop();
            onceTimer = null;
            updateSubtitles();
        }
	}
}