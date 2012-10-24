/*

ADOBE SYSTEMS INCORPORATED
Copyright 2011 Adobe Systems Incorporated
All Rights Reserved.

NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/

package com.adobe.nativeExtensions
{
	import flash.external.ExtensionContext;
	
	public class Vibration
	{
		// If the AIR application creates multiple Vibration objects,
		// all the objects share one instance of the ExtensionContext class.
		private static var extContext:ExtensionContext = null;
		
		public function Vibration()
		{
			trace ("Vibration Constructor");
			
			// If the one instance of the ExtensionContext class has not
			// yet been created, create it now.
			if (!extContext)
			{
				initExtension();
			}
		}
		
		public static function get isSupported():Boolean
		{
			trace ("Vibration isSupported()");
			
			// Because this is a static function, create the ExtensionContext object, if necessary.
			if (!extContext)
			{	
				initExtension();
			}
			
			return extContext.call("isSupported") as Boolean;
		}
		
		//Initialize the extension by calling our "initNativeCode" ANE function
		private static function initExtension():void
		{
			trace ("Vibration Constructor: Create an extension context");
			
			// The extension context's context type  is NULL, because this extension
			// has only one context type.
			extContext = ExtensionContext.createExtensionContext("com.adobe.Vibration", null);
			
			extContext.call("initNativeCode");
		}
		
		public function vibrate(duration:Number):void
		{
			trace ("Vibration vibrate()");
			
			// Note that the duration value, in milliseconds, applies to the Android implementation, but not
			// to the iOS implementation. The iOS implementation ignores the duration value.
			
			extContext.call("vibrateDevice", duration);
		}
	}
}