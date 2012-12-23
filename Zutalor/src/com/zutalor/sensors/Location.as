package com.zutalor.sensors 
{
	import flash.geom.Point;
	import flash.sensors.Geolocation;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Location 
	{
		
		public function Location() 
		{
			
		}
		
		public static function get location():Point
		{
			trace(Geolocation.isSupported);
			return new Point();
		}
		
	}

}