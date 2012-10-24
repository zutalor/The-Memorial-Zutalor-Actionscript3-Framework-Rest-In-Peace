package com.zutalor.events
{
	import flash.display.Bitmap;
	import flash.events.Event;
	
	

	/**
	 * The BitmapOpenEvent dispatches when an Bitmap has started downloading.
	 * 
	 * <script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	final public class BitmapOpenEvent extends Event
	{ 
		
		/**
		 * Defines the value of the type property of the bitmapOpen event type.
		 */
		public static const OPEN:String = "bitmapOpen";
		
		/**
		 * The Bitmap that started downloading.
		 */
		public var bitmap:Bitmap;
		
		/**
		 * Constructor for BitmapOpenEvent instances.
		 * 
		 * @param type The event type.
		 * @param bitmap	The Bitmap that is downloading.
		 */
		public function BitmapOpenEvent(type:String, bitmap:Bitmap)
		{
			super(type,false,false);
			this.bitmap = bitmap;
		}
		
		/**
		 * Clone this BitmapOpenEvent.
		 */
		override public function clone():Event
		{
			return new BitmapOpenEvent(type,bitmap);
		}
		
		/**
		 * To string override for descriptions.
		 */
		override public function toString():String
		{
			return "[BitmapOpenEvent bitmap:"+bitmap.name+"]";
		}
	}
}