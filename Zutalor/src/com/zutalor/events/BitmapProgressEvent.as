package com.zutalor.events
{
	import flash.display.Bitmap;
	import flash.events.Event;
	
	

	/**
	 * The BitmapProgressEvent dispatches for an Bitmap that is downloading.
	 * 
	 * <script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	final public class BitmapProgressEvent extends Event
	{ 
		
		/**
		 * Defines the value of the type property of the bitmapProgress event type.
		 */
		public static const PROGRESS:String = "bitmapProgress";
		
		/**
		 * The bitmap that is loading.
		 */
		public var bitmap:Bitmap;
		
		/**
		 * Constructor for BitmapProgressEvent instances.
		 * 
		 * @param type The type.
		 * @param bitmap	The Bitmap that is downloading.
		 */
		public function BitmapProgressEvent(type:String, bitmap:Bitmap)
		{
			super(type,false,false);
			this.bitmap = bitmap;
		}
		
		/**
		 * Clone this BitmapProgressEvent.
		 */
		override public function clone():Event
		{
			return new BitmapProgressEvent(type,bitmap);
		}
		
		/**
		 * To string override for descriptions.
		 */
		override public function toString():String
		{
			return "[BitmapProgressEvent bitmap:"+bitmap.name+"]";
		}
	}
}