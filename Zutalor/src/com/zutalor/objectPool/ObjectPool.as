package com.zutalor.objectPool 
{
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.containers.base.ContainerObject;
	import com.zutalor.containers.ParallaxContainer;
	import com.zutalor.containers.scrolling.ScrollingContainer;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.fx.Transition;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.view.utils.ViewCloser;
	import com.zutalor.view.rendering.ViewLoader;
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
		
		public static function getGraphic(name:String):Graphic
		{
			return new Graphic(name);
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
		
		public static function getContainer(vp:ViewProperties, scrollX:Boolean, scrollY:Boolean):void
		{
			switch (vp.containerType)
			{
				case ViewProperties.CONTAINER_SCROLLING :
					vp.container = new ScrollingContainer(vp.name, scrollX, scrollY);
					break;			
				case ViewProperties.CONTAINER_PARALLAX :
					vp.container = new ParallaxContainer(vp.name, scrollX, scrollY);
					break;		
				case ViewProperties.CONTAINER_BASIC :
				default :
					vp.container = new ViewContainer(vp.name);
					break;
			}
		}				
	}
}