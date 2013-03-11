package com.zutalor.transition
{
	import com.zutalor.utils.StageRef;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff
	 */
	public class BitMapSlide
	{
		private var bmd:BitmapData;
		private var bm:Bitmap;
		private var t:Transition;
		
		public function BitMapSlide()
		{
			bm = new Bitmap();
			t = new Transition();
			StageRef.stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			onResize();
		}
		
		private function onResize(e:Event = null):void
		{
			bmd = new BitmapData(StageRef.stage.stageWidth, StageRef.stage.stageHeight);
		}
		
		public function out(container:DisplayObject, transition:String):void
		{
			var transType:String;
			
			bmd.draw(container);
			bm.bitmapData = bmd;
			bm.visible = true;
			StageRef.stage.addChild(bm);

			t.simpleRender(bm, transition,"out" , hideBm);
			
			function hideBm():void
			{
				bm.visible = false;
			}
		}
	}

}