package com.zutalor.events
{
	import flash.display.Bitmap;
	import flash.events.Event;
	
	

	/**
	 * The BitmapErrorEvent dispatches when an bitmap has stopped loading due to an error.
	 * 
	 * <script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	final public class BitmapErrorEvent extends Event
	{ 
		
		/**
		 * Defines the value of the type propert yof the bitmapError event type.
		 */
		public static const ERROR:String = "bitmapError";
		
		/**
		 * The Bitmap that errored out.
		 */
		public var bitmap:Bitmap;
		
		/**
		 * Constructor for BitmapErrorEvent instances.
		 * 
		 * @param type The event type.
		 * @param bitmap	The Bitmap that errored out.
		 */
		public function BitmapErrorEvent(type:String, bitmap:Bitmap)
		{
			super(type,false,false);
			this.bitmap = bitmap;
		}
		
		/**
		 * Clone this BitmapErrorEvent.
		 */
		override public function clone():Event
		{
			return new BitmapErrorEvent(type,bitmap);
		}
		
		/**
		 * To string override for descriptions.
		 */
		override public function toString():String
		{
			return "[BitmapErrorEvent bitmap:"+bitmap.name+"]";
		}
	}
}