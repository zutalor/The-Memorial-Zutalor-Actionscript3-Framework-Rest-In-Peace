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
		private var _enabled:Boolean;
		
		public function Analytics() 
		{
			
		}
		
		public function initialize(params:Object):void
		{
			_enabled = params["enabled"];
			_tracker = new GATracker(params["display"], params["accountId"], "AS3", params["debug"] );

		}

		public function trackPageView(params:Object):void
		{
			if (_enabled)
				_tracker.trackPageview(params["page"]);
		}
	}	
}