package com.zutalor.utils
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Time
	{
		private var _onComplete:Function;
		private var _onCompleteArgs:*;
		private var _timer:Timer;
				
		public function delay(seconds:Number, onComplete:Function, onCompletArgs:*=null):void 
		{
			if (onComplete != null)
			{
				_onComplete = onComplete;
				_onCompleteArgs = onCompletArgs;
				if (!seconds || seconds <= 0)
					_onComplete();
				else
				{
					MasterClock.registerCallback(finished, true, seconds * 1000);
				}
			}
		}
		
		private function finished():void
		{
			MasterClock.unRegisterCallback(finished);
			if (_onCompleteArgs != null)
				_onComplete(_onCompleteArgs);
			else
				_onComplete();
		}
	}
}