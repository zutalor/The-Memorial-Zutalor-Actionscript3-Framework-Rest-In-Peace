package com.zutalor.utils 
{ 
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.SharedObject;
 
	public class NetworkInformation
	{ 
		public static function getHardwareAddress():String
		{ 
			var networkInfo:NetworkInfo = NetworkInfo.networkInfo; 
			var interfaces:Vector.<NetworkInterface> = networkInfo.findInterfaces(); 
			 
			if(interfaces != null && interfaces[0]) 
			{ 
				return interfaces[0].hardwareAddress;
			} 
			else
				return null;
		}  
	
		public static function getUniqueID(appName:String):String
		{
			var id:String;
			
			if (NetworkInfo.isSupported)
				id = getHardwareAddress();
			else
			{
				var so:SharedObject = SharedObject.getLocal(appName);
				
				if (!so.data.id)
				{
					id = so.data.id = GUID.create();
					so.flush();
				}
				else
					id = so.data.id;
			}
			return id;
		}
	}
}