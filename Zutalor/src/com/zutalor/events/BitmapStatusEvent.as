package com.zutalor.events
{
	import flash.display.Bitmap;
	import flash.events.Event;
	
	

	/**
	 * The BitmapStatusEvent dispatches for an Bitmap that had an HTTP status other than 0 or 200.
	 * 
	 * <script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	final public class BitmapStatusEvent extends Event
	{ 
		/**
		 * Defines the value of the type property of the bitmapStatus event type.
		 */
		public static const STATUS:String = "bitmapStatus";
		
		/**
		 * The Bitmap that had the status error.
		 */
		public var bitmap:Bitmap;
		
		/**
		 * The status code.
		 */
		public var status:int;
		
		/**
		 * Constructor for BitmapStatusEvent instances.
		 * 
		 * @param type The type.
		 * @param bitmap The Bitmap that triggered the status event.
		 * @param int The status code of the event.
		 */
		public function BitmapStatusEvent(type:String, bitmap:Bitmap, status:int)
		{
			super(type,false,false);
			this.bitmap = bitmap;
			this.status = status;
		}
		
		/**
		 * Clone this BitmapStatusEvent.
		 */
		override public function clone():Event
		{
			return new BitmapStatusEvent(type,bitmap,status);
		}
		
		/**
		 * To string override for descriptions.
		 */
		override public function toString():String
		{
			return "[BitmapStatusEvent bitmap:"+bitmap.name+"]";
		}
	}
}