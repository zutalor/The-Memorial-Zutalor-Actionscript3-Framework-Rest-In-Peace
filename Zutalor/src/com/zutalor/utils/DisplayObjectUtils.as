package com.zutalor.utils  
{
	import com.gskinner.utils.IDisposable;
	import com.zutalor.objectPool.ObjectPool;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.media.Camera;
	import flash.media.Video;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class DisplayObjectUtils
	{
		
		public function DisplayObjectUtils() 
		{
			
		}
		
		public static function removeAllChildren(d:DisplayObjectContainer):void		
		{
			if(d.numChildren<1) return;
			
			var l:int;
			var c:*;
			var i:int;
			var childToRemove:int;
			
			childToRemove = 0;
			l = d.numChildren;
			
			for (i = 0; i < l; i++)
			{	
				try {
				c = d.removeChildAt(childToRemove);
				} catch (c:*) {}
				//if (c is DisplayObjectContainer)  //TODO: See why this breaks other things.
				//	removeAllChildren(c);
				if (c is MovieClip) {
					(c as MovieClip).stop(); 
				}
				/*
				if (c is Bitmap && (c as Bitmap).bitmapData != null) {
					(c as Bitmap).bitmapData.dispose();
				}
				*/
				if (c is Video)
					c.attachCamera(null);
				
				if (c is Loader) {
					cleanUpConnection(d as Loader);
				}
				// use try/catch instead of IDisposable so that we can define dispose in timeline code:
				try {
					(c as Object).dispose();
				} catch (c:*) {}				
				ObjectPool.recycle(c);
			}	
		}
		
		private static function cleanUpConnection(p_conn:Object):void {
			// because we're unsure what type of connection we have, and what it's status is, we have to use try catch:
			try {
				var content:Object = p_conn.content;
				if (content is IDisposable) { content.dispose(); }
			} catch (e:*) {}
			try {
				p_conn.close();
			} catch (e:*) {}
			try {
				p_conn.unload();
			} catch (e:*) {}
			try {
				p_conn.cancel();
			} catch (e:*) {}
		}
		
	}

}