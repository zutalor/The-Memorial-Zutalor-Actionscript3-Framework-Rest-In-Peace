package com.zutalor.analytics 
{
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Analytics
	{
		private var _tracker:AnalyticsTracker;		
		
		public function Analytics() 
		{
			
		}
		
		public function initialize(params:Object):void
		{
			trace(params[0], params[1], params[2]);
			_tracker = new GATracker(params["display"], params["accountId"], "AS3", params["debug"] );

		}

		public function trackPageView(params:Object):void
		{
			_tracker.trackPageview(params["page"]);
		}
	}	
}