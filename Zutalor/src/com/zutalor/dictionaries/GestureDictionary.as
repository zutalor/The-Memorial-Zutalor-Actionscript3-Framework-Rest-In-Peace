package com.zutalor.dictionaries 
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.utils.gDictionary;
	import org.gestouch.gestures.Gesture;
	/**
	 * ...
	 * @author Geoff
	 */
	public class GestureDictionary extends gDictionary implements IDisposable
	{
		
		public function GestureDictionary() 
		{
			
		}
		
		override public function insert(key:string, obj:Gesture, newkey:*=null):void
		{
			super.insert(key, obj, newkey);
		}
	}
}