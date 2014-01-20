package com.zutalor.utils 
{ 
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
 
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
	}
}