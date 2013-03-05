package com.zutalor.amfphp
{
	import com.zutalor.utils.ShowError;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.registerClassAlias;
	import flash.net.Responder;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Remoting
	{
		private var _onFailure:Function;
		private var _onSuccess:Function;
		private static var _gateway:String;
		
		public function Remoting()
		{

		}
		
		public static function set gateway(gw:String):void
		{
			_gateway = gw;
		}
		
		public static function get gateway():String
		{
			return _gateway;
		}

		public function call(command:String, classAlias:String=null, Klass:Class=null, onSuccess:Function=null, onFailure:Function=null, ... args:*):void
		{
			var gw:NetConnection;
			var res:Responder;
			
			if (!_gateway)
				ShowError.fail(Remoting, "No Gateway defined in Remoting.");
			
 			_onFailure = onFailure;
			_onSuccess = onSuccess;
			
			if (Klass)
				registerClassAlias(classAlias, Klass);
			
			gw = new NetConnection();
			gw.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			res = new Responder(onResult, onError);
			
			gw.connect(gateway);
			
			gw.call.apply(null, [command, res].concat(args)); // this was pretty tricky to figure out.
			
			function onResult(pVO:Object):void
			{
				cleanup();
				trace("success", pVO);
				if (_onSuccess != null)
					_onSuccess(pVO);
			}
			
			function onError(result:Object=null):void
			{
				cleanup();
				if (_onFailure != null)
					_onFailure(result);
			}
			
			function cleanup():void
			{
				gw.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				gw.close();
				gw = null;
				res = null;
			}
		}
			
		public function onNetStatus(e:NetStatusEvent):void
		{
			switch (e.info.code)
			{
				case "NetConnection.Call.Failed" :
					if (_onFailure != null)
						_onFailure(e.info.code);
					break;
			}
			trace(e.info.code);
		}
	}
}