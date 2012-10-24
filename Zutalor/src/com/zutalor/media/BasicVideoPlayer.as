package com.zutalor.media
{
	import com.greensock.loading.core.DisplayObjectLoader;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.media.VideoController;
	import com.zutalor.utils.DisplayObjectUtils;
	import com.zutalor.utils.ObjectUtil;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class BasicVideoPlayer extends Sprite implements IDisposable
	{
		public var vController:VideoController;
		
		public function BasicVideoPlayer() 
		{
			
		}
		
		public function load(url:String, width:int, height:int):void
		{
			if (vController)
				dispose();
				
			vController = new VideoController();
			vController.load(this, url, width, height, false);
		}
		
		public function stop():void
		{
			vController.stop();
		}
		
		public function pause():void
		{
			vController.pause();
		}
				
		public function play(seekPos:Number=0):void
		{
			vController.play(seekPos);
		}
		
		public function dispose():void
		{
			vController.stop();
			vController.dispose();
			vController = null;
			DisplayObjectUtils.removeAllChildren(this);
		}
	}
}