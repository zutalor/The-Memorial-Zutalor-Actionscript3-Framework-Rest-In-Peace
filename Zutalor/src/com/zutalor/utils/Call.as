package com.zutalor.utils
{
	/**
	 * ...
	 * @author Geoff
	 */
	public class Call
	{
		
		public function Call()
		{
			
		}
		
		public static function method(method:Function = null, args:* = null):void
		{
			if (method != null)
			{
				if (args)
					method(args);
				else
					method();
			}
		}
	}
}