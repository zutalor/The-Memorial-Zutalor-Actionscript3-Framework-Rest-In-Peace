package com.zutalor.air
{
	import com.gskinner.utils.FramerateThrottler;
	import com.zutalor.utils.StageRef;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class AirPlugin
	{
		private var _nativeApplication:Boolean;
		private var _isPortable:Boolean;
		
		public function AirPlugin() 
		{
		}
		
		public function get isNativeApplication():Boolean
		{
			return _nativeApplication;
			
		}
		
		public function get isPortable():Boolean
		{
			return _isPortable;
		}		
		
		public function initialize():void
		{
			FramerateThrottler.initialize();
		
			if (Capabilities.playerType == "Desktop")
			{
				_nativeApplication = true;
			}
			
			else if (Capabilities.cpuArchitecture=="ARM")
			{
				_nativeApplication = true;
				_isPortable = true;
			}	
			
			if (_nativeApplication)
			{
				FramerateThrottler.initialize();
				NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
			}
		}
		
		public function nwClose():void
		{
			StageRef.stage.nativeWindow.close();			
		}
		
		public function nativeApplicationExit():void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		public function nwMinimize():void
		{
			StageRef.stage.nativeWindow.minimize();
		}

		public function nwMaximize():void
		{
			StageRef.stage.nativeWindow.maximize();
		}
		
		public function nwStartMove():void
		{
			StageRef.stage.nativeWindow.startMove();
		}
		
		private function applicationExit():void 
		{
			var exitingEvent:Event = new Event(Event.EXITING, false, true);
			NativeApplication.nativeApplication.dispatchEvent(exitingEvent);
			if (!exitingEvent.isDefaultPrevented())
				NativeApplication.nativeApplication.exit();
		}	
			
		private function onExiting(exitingEvent:Event):void {
			var winClosingEvent:Event;
			for each (var win:NativeWindow in NativeApplication.nativeApplication.openedWindows) {
				winClosingEvent = new Event(Event.CLOSING,false,true);
				win.dispatchEvent(winClosingEvent);
				if (!winClosingEvent.isDefaultPrevented()) {
					win.close();
				} else {
					exitingEvent.preventDefault();
				}
			}
			
			if (!exitingEvent.isDefaultPrevented()) {
				//perform cleanup
			}
		}		
	}
}