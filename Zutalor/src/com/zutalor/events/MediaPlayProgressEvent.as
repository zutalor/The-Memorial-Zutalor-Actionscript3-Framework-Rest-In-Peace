/**
* @description  
*/
package com.zutalor.events
{

	import flash.events.Event;
	
	public class MediaPlayProgressEvent extends Event {
		

		public static const PROGRESS:String = "mediaprogress";
		
		private var _currentTime:Number;
		private var _totalTime:Number;
		
		public function MediaPlayProgressEvent(
			pType:String,
			pTotalTime:Number = 0,
			pCurrentTime:Number = 0,
			pBubbles:Boolean=false,
			pCancelable:Boolean=false
		) {
			super(pType, pBubbles, pCancelable);
			_currentTime = pCurrentTime;
			_totalTime = pTotalTime;
		}
		
		public function get currentTime():Number { return _currentTime; }
		
		public function get totalTime():Number { return _totalTime; }
		
		public function get percentPlayed():Number { return _currentTime / _totalTime; }
	}
}