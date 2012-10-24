package com.zutalor.utils 
{
	/**
	 * ...
	 * @author G Pepos
	 */
	public class Path 
	{
		private static var paths:Array = [];
		
		public static function addPath(pathId:String, path:String):void
		{
			paths[pathId]=path;
		}
		
		/**
		 * Get a path concatenated from the given pathIds - if ExternalInterface is
		 * available, it uses the guttershark javascript api. Otherwise it's stored in a local
		 * dictionary.
		 * 
		 * @param ...pathIds An array of pathIds whose values will be concatenated together.
		 */
		public static function getPath(...pathIds:Array):String
		{
			var fp:String="";
			var i:int=0;
			var l:int=pathIds.length;
			for(i;i<l;i++)
			{
				if(paths[pathIds[i]])
					fp += paths[pathIds[i]];
			}
			return fp;
		}
	}
}