package com.zutalor.ui
{
	import adobe.utils.CustomActions;
	import flash.display.Sprite;
	import com.zutalor.utils.MathG;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.zutalor.graphics.Ball;
	import com.zutalor.utils.Motion;
	
	/**
	 * Draws a dynamic physics based "rope/cable" from a point to a point.
	 * @author Geoffrey Pepos
	 */
	 
	public class Rope extends Sprite
	{
		public var lineStyle:Number = 1;
	
		private var isSpringing:Boolean = false;
		private var isInitialized:Boolean = false;			
		private var springingTimer:Timer = new Timer(4500,1);
		
		private var fromX:int;
		private var toX:int;
		private var fromY:int;
		private var toY:int;
		
		private var color:uint;
		
		private var balls:Array = [];
		private var numBalls:int = 17;

		// mess with these at your peril.
		private var gravity:Number = 0.07;		// .07
		private var spring:Number = .19;		// .19
		private var friction:Number = .77;		// .77
		private var springLength:Number = 1;	// 1
				
		public function Rope():void  // constructor
		{		
		}
		
		public function tieRope(fromX:Number, fromY:Number, toX:Number, toY:Number, color:uint = 0):void
		{	
			this.fromX = fromX;
			this.fromY = fromY;
			this.toX = toX;
			this.toY = toY;
			this.color = color;
			
			if (isSpringing) // we were called again before springing stopped.
			{
				removeEventListener(Event.ENTER_FRAME, springRope);
				springingTimer.reset();
				springingTimer.removeEventListener(TimerEvent.TIMER, stopSpringing);
			}
			else
			{
				if (!isInitialized) {		// we do this here because the constructor doesn't know
					initRope();		  		// the x,y coordinates...only tieRope gets those.	
					isInitialized = true;	// Rope is meant for dynamic positioning of the ends.
				}
			}
			isSpringing = true;
			springingTimer.addEventListener(TimerEvent.TIMER, stopSpringing, false, 0, true);
			springingTimer.start();
			addEventListener(Event.ENTER_FRAME, springRope, false, 0, true, false, 0, true);
		}		
		
		private function stopSpringing(event:TimerEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, springRope);
			springingTimer.removeEventListener(TimerEvent.TIMER, stopSpringing);
			isSpringing = false;
		}
	
		private function initRope():void
		{
			var p:Point;
			
			for (var i:int = 0; i < numBalls; i++ )
			{
				balls[i] = new Ball(3); // these are the the objects that are actually springing.
				addChild(balls[i]);
				balls[i].visible = false;
				
				// this places the "balls" on a straight line between from and to based on percentage.
				p = MathG.GetPointOnLine(fromX, fromY, toX, toY, ((100 / numBalls) * i) / 100);		
				balls[i].x = p.x;
				balls[i].y = p.y;
			}	
			balls[0].visible = true;
			balls[numBalls - 1].visible = true;
		}

		private function springRope(event:Event):void
		{
			for (var i:int = 0; i < numBalls - 1; i++ )
			{
				Motion.springTo(balls[i], balls[i + 1], gravity, spring, friction, springLength);
				Motion.springTo(balls[i + 1], balls[i], gravity, spring, friction, springLength);
			}
			// keep the ends attached.
			balls[0].x = fromX;
			balls[0].y = fromY;
			balls[numBalls - 1].x = toX;
			balls[numBalls - 1].y = toY;
			drawRope();
		}	
		
		// draws lines between the springy balls.
		private function drawRope():void
		{	
			graphics.clear();
			graphics.lineStyle(lineStyle, color);
			for (var i:int = 0; i < numBalls - 1; i++ )
			{
				graphics.moveTo(balls[i].x, balls[i].y);
				graphics.lineTo(balls[i+1].x, balls[i+1].y);			
			}			
		}
	}
}
