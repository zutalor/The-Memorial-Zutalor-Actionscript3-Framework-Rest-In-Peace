package com.zutalor.utils 
{
	import flash.display.Stage;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class StageRef
	{
		private static var _stage:Stage;
				
		public static function get stage():Stage
		{
			return _stage;
		}
		
		public static function set stage(s:Stage):void
		{
			_stage = s;
		}
	}

}