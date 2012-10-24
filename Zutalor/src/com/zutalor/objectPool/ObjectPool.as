package com.zutalor.objectPool 
{
	import com.zutalor.containers.MaskedContainer;
	import com.zutalor.containers.ParallaxContainer;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.containers.StandardContainer;
	import com.zutalor.fx.Transition;
	import com.zutalor.properties.ViewProperties;
	import com.zutalor.ui.Graphic;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.ViewCloser;
	import com.zutalor.view.ViewLoader;
	import flash.display.Sprite;
	import flash.media.StageVideo;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff Pepos
	 * TODO really make this an object pool!
	 */
	public class ObjectPool
	{	
		private static var curStageVidPlayer:int;
		
		public static function recycle(obj:*):void // listeners should have been already removed before calling this.
		{
			obj = null; 
		}
		
		public static function getStageVideo():StageVideo
		{
			var sv:StageVideo;
			
			if (curStageVidPlayer == StageRef.stage.stageVideos.length)
				curStageVidPlayer = 0;
			
			sv = StageRef.stage.stageVideos[curStageVidPlayer];
			curStageVidPlayer++;
			return sv;
		}
		
		public static function getGraphic():Graphic
		{
			return new Graphic();
		}
		
		public static function getSprite():Sprite
		{
			return new Sprite();
		}
		
		public static function getTextField():TextField
		{
			return new TextField();
		}
		
		public static function getTransition():Transition
		{
			return new Transition();
		}
		
		public static function getViewLoader():ViewLoader
		{
			return new ViewLoader();
		}
		
		public static function getViewCloser():ViewCloser
		{
			return new ViewCloser();
		}
		
		public static function getContainer(vp:ViewProperties):void
		{
			switch (vp.containerType)
			{
				case ViewProperties.CONTAINER_SCROLLING :
					vp.container = new ScrollingContainer(vp.name, vp.width, vp.height, vp.hScrollBarSliderId, 
																vp.vScrollBarSliderId, vp.autoAdjustThumbSize);
					break;
				case ViewProperties.CONTAINER_MASKED :
					vp.container = new MaskedContainer(vp.name, vp.width, vp.height);
					break;					
				case ViewProperties.CONTAINER_PARALLAX :
					vp.container = new ParallaxContainer(vp.name, vp.width, vp.height, vp.hScrollBarSliderId, 
																vp.vScrollBarSliderId, vp.autoAdjustThumbSize);
					break;		
				case ViewProperties.CONTAINER_BASIC :
					vp.container = new StandardContainer(vp.name, vp.width, vp.height);
					break;
				default :
					vp.container = new StandardContainer(vp.name, vp.width, vp.height);
					break;
			}
		}				
	}
}