package com.zutalor.events
{
	import flash.display.Bitmap;
	import flash.events.Event;
	
	

	/**
	 * The BitmapCompleteEvent dispatches when an bitmap has completed downloading.
	 * 
	 * <script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	final public class BitmapCompleteEvent extends Event
	{
		
		/**
		 * Defines the value of the type property of the bitmapComplete event type.
		 */
		public static const COMPLETE:String = 'bitmapComplete';
		
		/**
		 * The bitmap that has completely downloaded.
		 */
		public var bitmap:Bitmap;
		
		/**
		 * Constructor for BitmapCompleteEvent instances.
		 * 
		 * @param type The event type.
		 * @param bitmap The Bitmap that has completely downloaded.
		 */
		public function BitmapCompleteEvent(type:String,bitmap:Bitmap)
		{
			super(type,false,false);
			this.bitmap = bitmap;
		}
		
		/**
		 * Clone this BitmapCompleteEvent.
		 */
		override public function clone():Event
		{
			return new BitmapCompleteEvent(type,bitmap);
		}
		
		/**
		 * To string override for descriptions.
		 */
		override public function toString():String
		{
			return "[BitmapCompleteEvent bitmap:"+bitmap.name+"]";
		}
	}
}