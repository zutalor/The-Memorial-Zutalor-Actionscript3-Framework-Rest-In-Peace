package com.zutalor.animations 
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenMax;
	import com.greensock.TweenMax;
	import com.zutalor.media.VideoController;
	import com.zutalor.media.VideoPlayer;
	import com.zutalor.sprites.MotionSprite;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.TimerRegistery;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Eagle extends Sprite
	{
		private var eagleVidController:VideoController;
		private var _eagleIsFlying:Boolean;
		private var _eagleIsStopped:Boolean;
		
		public function Eagle() 
		{
			eagleVidController = new VideoController(0);
		}
					
		public function loadEagle():void
		{	
			eagleVidController.load(this, "assets/video/eagle.flv", 70, 70, -1);
			this.visible = false;
			_eagleIsFlying = false;
		}
		
		public function startEagleTimer():void
		{	
			_eagleIsStopped = false;
			MasterClock.registerCallback(flyEagle,true, 2000);
		}
								
		private function flyEagle():void
		{
			var destX:int;
			var destY:int;

			if (!_eagleIsFlying && !_eagleIsStopped)
			{
				if (MathG.rand(1, 10) == 7 || event == null)
				{
					_eagleIsFlying = true;
					this.visible = true;
					this.alpha = 1;

					destX = -80;
					destY = stage.stageHeight / MathG.rand(2, 7);
					
					this.scaleX = this.scaleY = MathG.randFloat(.25, 1);

					eagleVidController.play();
					this.x = stage.stageWidth + 80;
					this.y = stage.stageHeight / MathG.rand(4,7);
				
					TweenMax.to(this, MathG.rand(7,20), { x:destX, y:destY, ease:Linear.easeNone, onComplete:destinationReached } );
				}
			}
		}
		
		private function destinationReached(e:Event = null):void
		{
			eagleVidController.stop();
			this.visible = false;
			_eagleIsFlying = false;
		}		
				
		public function stopEagle():void
		{
			TweenMax.to(this, 1, { alpha:0, overwrite:2, onComplete:destinationReached } );
			_eagleIsStopped = true;
		}	
		
		public function resumeEagle():void
		{
			_eagleIsStopped = false;
		}
	}
}