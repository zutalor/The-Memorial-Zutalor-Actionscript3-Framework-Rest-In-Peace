package com.zutalor.utils
{
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ObjectUtil
	{
		
		public static function concat(... rest):Object 
		{			
			var destObj:Object;
			
			destObj = {};
			
			for each (var srcObj:Object in rest)
			{
				if (srcObj)
					for (var i:String in srcObj)
						destObj[i] = srcObj[i];				
			}
			return destObj;
		}
	}
}