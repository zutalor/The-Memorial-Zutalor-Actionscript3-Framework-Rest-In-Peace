package com.zutalor.p2p
{
	import com.projectcocoon.p2p.events.ClientEvent;
	import com.projectcocoon.p2p.events.GroupEvent;
	import com.projectcocoon.p2p.events.MessageEvent;
	import com.projectcocoon.p2p.LocalNetworkDiscovery;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	final public class P2PTransponder
	{	
		private var _channel:LocalNetworkDiscovery;
		
		public static const CLIENT_ADDED:String= ClientEvent.CLIENT_ADDED;
		public static const CLIENT_REMOVED :String = ClientEvent.CLIENT_REMOVED;
		public static const CLIENT_UPDATE :String = ClientEvent.CLIENT_UPDATE;
		public static const GROUP_CONNECTED:String = GroupEvent.GROUP_CONNECTED;
		public static const GROUP_CLOSED:String = GroupEvent.GROUP_CLOSED;
		public static const DATA_RECEIVED:String = MessageEvent.DATA_RECEIVED;
	
		public function P2PTransponder(clientName:String)
		{
			_construct(clientName);
		}
		
		//PUBLIC METHODS
		
		private function _construct(clientName:String):void
		{			
			_channel = new LocalNetworkDiscovery();
			_channel.clientName = clientName;
			_channel.connect();
		}
						
		public function get channel():LocalNetworkDiscovery
		{
			return _channel
		}
		
		public function sendMessageToAll(message:Object):void
		{
			channel.sendMessageToAll(message);
		}
		
		public function sendMessageToClient(client:String, message:Object):void
		{
			channel.sendMessageToClient(message, client);
		}
	}
}