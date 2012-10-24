/**
* @description  
*/
package com.zutalor.events
{

	import flash.events.Event;
	
	public class MediaEvent extends Event {
		
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause";
		public static const STOP:String = "stop";
		public static const MUTE:String = "mute";
		public static const UNMUTE:String = "unmute";
		public static const NEXT:String = "next";
		public static const PREV:String = "prev";
		public static const VOLUME_CHANGE:String = "volume_change";
		public static const PAN_CHANGE:String = "pan_change";
		public static const RESIZE:String = "resize";
		public static const SEEK:String = "seek";
		public static const BUFFER_FULL:String = "buffer_full";
		public static const BUFFER_EMPTY:String = "buffer_empty";
		public static const BUFFER_FLUSH:String = "buffer_flush";
		public static const STREAM_NOT_FOUND:String = "stream_not_found";
		public static const SEEK_INVALID_TIME:String = "seek_invalid_time";
		public static const SEEK_NOTIFY:String = "seek_notify";
		public static const COMPLETE:String = "complete";
		public static const OVERLAP:String = "overlap";
		public static const START_FADE:String = "startFade";
		public static const METADATA:String = "metadata";
		public static const CUEPOINT:String = "cuepoint";
		public static const RECYCLED:String = "recycled";
		
		private var _volume:Number; 
		private var _mute:Boolean; 
		private var _pan:Number; 
		private var _seekPercent:Number;
		
		/**
		* @description  Constructor.
		*
		* @param  pType  The event name.
		* @param  pVolume 
		* @param  pPan  
		* @param  pBubbles  Whether the event bubbles up through the display list.
		* @param  pCancelable  Whether the event can be canceled as it bubbles.
		*/
		public function MediaEvent
		(
			pType:String,
			pPercentPlayed:Number = 0,
			pPercentLoaded:Number = 0,
			pSeekPercent:Number = 0,
			pVolume:Number = 0,
			pMute:Boolean = false,
			pPan:Number = 0,
			pTotalTime:Number = 0,
			pCurrentTime:Number = 0,
			pBubbles:Boolean=false,
			pCancelable:Boolean=false
		) {
			super(pType, pBubbles, pCancelable);
			_seekPercent = pSeekPercent;
			_volume = pVolume;
			_mute = pMute;
			_pan = pPan;
		}
		
		public function get volume():Number { return _volume; }
		
		public function get seekPercent():Number { return _seekPercent; }
		
		public function get mute():Boolean { return _mute; }		
	}
}