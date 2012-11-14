package com.zutalor.utils 
{
	import com.zutalor.properties.PathProperties;
	import com.zutalor.propertyManagers.Props;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Path 
	{
		
		public function Path() 
		{
			
		}
		
		public static function getPath(p:String):String
		{
			var pp:PathProperties;
			
			pp = Props.paths.getPropsByName(p);
			if (pp)
				return(pp.path);
			else
				return "";
		}
	}

}