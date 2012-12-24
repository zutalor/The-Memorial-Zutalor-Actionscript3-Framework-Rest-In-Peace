package com.zutalor.sensors 
{
	import flash.events.GeolocationEvent;
	import flash.geom.Point;
	import flash.sensors.Geolocation;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Location 
	{
		public var geoLocation:Geolocation;
		
		public function Location() 
		{
			geoLocation = new Geolocation;
		}
		
		public function get location():Point
		{
			trace(Geolocation.isSupported);
			geoLocation.addEventListener(GeolocationEvent.UPDATE, onGeolocationUpdate);
			return new Point();
		}
		
		private function onGeolocationUpdate(ge:GeolocationEvent):void
		{
			
		}
	}

}