package com.zutalor.transition 
{
	/**
	 * ...
	 * @author Geoff
	 */
	public class BitMapSlide 
	{
		
		public function BitMapSlide() 
		{
			
		}
		
		var t:Transition;
			var bmd:BitmapData;
			var bm:Bitmap;
			
			if (transition)
			{
				bmd = new BitmapData(StageRef.stage.stageWidth, StageRef.stage.stageHeight);
				bmd.draw(vp.container);
				bm = new Bitmap(bmd);
				bm.visible = true;
				StageRef.stage.addChild(bm);				
				t = new Transition();
				t.simpleRender(bm, transition, "out", hideBm);
				
				function hideBm():void
				{
					bm.visible = false;
				}
			}
		
	}

}