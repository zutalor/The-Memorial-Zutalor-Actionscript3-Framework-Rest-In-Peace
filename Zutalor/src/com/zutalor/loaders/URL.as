package com.zutalor.loaders 
{
	import flash.net.navigateToURL;
	import flash.net.sendToURL;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class URL 
	{		
		public static function open(url:String, window:String = "_blank"):void 
		{
			var request:URLRequest = new URLRequest(url);
			navigateToURL(request,window);
		}
		
		public static function send(url:String):void
		{
			var request:URLRequest = new URLRequest(url);
			sendToURL(request);
		}
		
		public static function sendVars(url:String, vars:URLVariables, method:String, window:String= "_self"):void		
		{
			var data:URLRequest = new URLRequest(url);
			data.method = method;
			data.data = vars;
			navigateToURL(data, window);
		}
	}
}