package com.zutalor.analytics 
{
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;
	import com.zutalor.air.AirStatus;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Analytics
	{
		private static var _tracker:AnalyticsTracker;		
		public static var enabled:Boolean;
		
		public function Analytics() 
		{
			
		}
		
		public static function initialize(display:DisplayObject, accountId:String, debug:Boolean = false):void
		{
			if (accountId)
			{
				enabled = true;
				_tracker = new GATracker(display, accountId, "AS3", debug);
			}
		}

		public static function trackPageView(page:String):void
		{
			if (enabled)
			{
				if (AirStatus.isNativeApplication)
					_tracker.trackPageview(" " + page);
				else
					_tracker.trackPageview(page);
			}
		}
	}	
}