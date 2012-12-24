package com.zutalor.utils
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class EmbeddedResources
	{
		
		private static var _resourceClass:*;
				
		public static function register(resourceClass:*):void
		{
			if (_resourceClass)
				ShowError.fail(EmbeddedResources,"Current implementation only supports one registration.");
			else	
				_resourceClass = new resourceClass();
		}
		
		public static function getClass(className:String):Class
		{
			return _resourceClass[className];
		}
						
		public static function createInstance(className:String):*
		{
			var obj:*;
			var s:Sprite;
			var Klass:Class;
			
			try {
				Klass = _resourceClass[className];
				obj = new Klass();					
			} catch (e:*) { }
			
			if (!obj)
				ShowError.fail(EmbeddedResources,"Could not create class: " + className);
			else if (obj is Bitmap)
				obj.smoothing = true;
			
			return obj;
		}
	}
}