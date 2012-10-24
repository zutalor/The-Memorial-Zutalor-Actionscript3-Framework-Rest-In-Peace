package com.zutalor.utils  
{
	import com.zutalor.utils.StageRef;
	import flash.display.StageDisplayState;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class FullScreen
	{
		public static function toggle():void
		{
			if (!StageRef.stage) return;
			
			if (StageRef.stage.displayState == StageDisplayState.FULL_SCREEN || StageRef.stage.displayState == "fullScreenInteractive") 
			{
				StageRef.stage.displayState = StageDisplayState.NORMAL;
			}
			else if (Capabilities.playerType == "Desktop" || Capabilities.playerType=="StandAlone")
				StageRef.stage.displayState = "fullScreenInteractive";
			else 
				StageRef.stage.displayState=StageDisplayState.FULL_SCREEN;
		}
		
		public static function full():void
		{
			if (Capabilities.playerType == "Desktop" || Capabilities.playerType=="StandAlone")
				StageRef.stage.displayState = "fullScreenInteractive";
			else 
				StageRef.stage.displayState=StageDisplayState.FULL_SCREEN;			
		}
		
		public static function restore():void
		{
			if (StageRef.stage.displayState == StageDisplayState.FULL_SCREEN || StageRef.stage.displayState == "fullScreenInteractive") 
			{
				StageRef.stage.displayState = StageDisplayState.NORMAL;
			}			
		}
		
		public static function restoreIfNotDesktop():void
		{
			if (!(Capabilities.playerType == "Desktop" || Capabilities.playerType == "StandAlone"))
				StageRef.stage.displayState = StageDisplayState.NORMAL;
		}
	}
}