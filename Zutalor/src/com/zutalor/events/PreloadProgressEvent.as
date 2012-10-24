package com.zutalor.events
{
	import flash.events.Event;	

	/**
	 * The PreloadProgressEvent dispatches to notify listeners the overall
	 * progress of a PreloadController.
	 * 
	 * <script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	final public class PreloadProgressEvent extends Event
	{
		
		/**
		 * Defines the value of the type property of the preloadProgress event type.
		 */
		public static const PROGRESS:String = "preloadProgress";
		
		/**
		 * The number of pixels that are "filled" based off of the overall progress.
		 */
		public var pixels:int;
		
		/**
		 * The percent complete of the overall assets to download.
		 */
		public var percent:Number;
		
		public var message:String;
		
		/**
		 * Constructor for PreloadProgressEvent instances.
		 * 
		 * @param type The event type.
		 * @param pixels The amount of pixels.
		 * @param percent The percent complete.
		 */
		public function PreloadProgressEvent(type:String, pixels:int, percent:Number, message:String= null):void
		{
			super(type,false,false);
			this.pixels = pixels;
			this.percent = percent;
			this.message = message;
		}
		
		/**
		 * Clone this PreloadProgressEvent.
		 */
		override public function clone():Event
		{
			return new PreloadProgressEvent(type,pixels,percent, message);
		}
		
		/**
		 * To string override for descriptions.
		 */
		override public function toString():String
		{
			return "[PreloadProgressEvent pixels: "+pixels+" percent: "+percent+"]";
		}
	}
}
