/**
* @description  
*/
package com.zutalor.events
{

	import flash.events.Event;
	
	public class MediaLoadProgressEvent extends Event {
		

		public static const PROGRESS:String = "medialoadprogress";
		
		private var _percentLoaded:Number;
		
		public function MediaLoadProgressEvent(
			pType:String,
			pPercentLoaded:Number = 0,
			pBubbles:Boolean=false,
			pCancelable:Boolean=false
		) {
			super(pType, pBubbles, pCancelable);
			_percentLoaded = pPercentLoaded;
		}		
		public function get percentLoaded():Number { return _percentLoaded; }
	}
}