package com.zutalor.utils 
{
	import adobe.utils.CustomActions;
	import com.greensock.easing.Quint;
	import com.greensock.TweenMax;
	import com.zutalor.containers.StandardContainer;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.sprites.MotionSprite;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Motion
	{	
		public static function isContainerInMotion(c:StandardContainer):Boolean
		{
			var ms:MotionSprite;
			
			for (var i:int = 0;  i < c.numChildren; i++)
			{
				ms = c.getChildAt(i) as MotionSprite;
				if (ms.inMotion)
				{
					return true;
				}
			}
			return false;
		}
		
		public static function checkMotion(ms:MotionSprite, velocityTolerance:Number, maxVelocity:Number):void
		{	
			if (ms.vx > maxVelocity)
				ms.vx = maxVelocity;
				
			if (ms.vy > maxVelocity)
				ms.vy = maxVelocity;
				
			if (Math.abs(ms.vx) < velocityTolerance && Math.abs(ms.vy) < velocityTolerance)
			{
				ms.inMotion = false;
				ms.vx = 0;
				ms.vy = 0;
			} 
			else 
			{
				ms.inMotion = true;
			}
		}
		
		public static function checkBounds(width:Number, height:Number, ms:MotionSprite, overlap:Number = 75):void
		{
			var left:Number;
			var right:Number;
			var top:Number;
			var bottom:Number;
			
			
			var bounce:Number = -.5;
			
			
			bottom = height + ms.height - overlap;
			right = width + ms.width - overlap;
			top = (ms.height - overlap) * -1;
			left = (ms.width - overlap) * -1;
			
			if ( ms.x + ms.width > right)
			{
				ms.x = right - ms.width;
				ms.vx *= bounce;
				squashAndStretch(ms);
			}
			else if(ms.x < left)
			{
				ms.x = left;
				ms.vx *= bounce;
				squashAndStretch(ms);
			}
			
			if (ms.y + ms.height > bottom)
			{
				ms.y = bottom - ms.height;
				ms.vy *= bounce;
				squashAndStretch(ms);
			}
			else if(ms.y < top)
			{
				ms.y = top;
				ms.vy *= bounce;
				squashAndStretch(ms);
			}
		}
		
		public static function squashAndStretch(ms:MotionSprite):void
		{
			//TweenMax.from(ms, .5, { scaleY:ms.scaleY * .75, scaleX:ms.scaleX * .75, ease: Quint.easeOut } );
		}		

		public static function chainContainerChildren(c:StandardContainer, springLength:Number = 50):void 
		{		
			var gravity:Number = 0
			var spring:Number = .05;
			var friction:Number = .95;
			
			if (Motion.isContainerInMotion(c))
			{
				var ms:MotionSprite;
				
				for (var i:int = 0;  i < c.numChildren - 1; i++)
				{
					ms = c.getChildAt(i) as MotionSprite;
					if (!ms.dragging) 
					{
						Motion.springTo(c.getChildAt(i), c.getChildAt(i + 1), gravity, spring, friction, springLength); 
					}
					
					ms = c.getChildAt(i + 1) as MotionSprite;
					if (!ms.dragging)
					{
						Motion.springTo(c.getChildAt(i + 1), c.getChildAt(i), gravity, spring, friction, springLength);
					}
				}
				//if (!c.getChildAt(c.numChildren - 1).dragging)
				//{
				//		Motion.springTo(c.getChildAt(c.numChildren- 1), c.getChildAt(c.numChildren - 2), gravity, spring, friction, springLength);
				//}	
			}
		}
		
		public static function checkForCollision(container:StandardContainer, spring:Number = .05):void
		{		
			if (Motion.isContainerInMotion(container))
			{
				for (var i:uint = 0; i < container.numChildren - 1; i++)
				{
					var ms0:MotionSprite = container.getChildAt(i) as MotionSprite;
					for (var j:uint = i + 1; j < container.numChildren; j++)
					{
						var ms1:MotionSprite = container.getChildAt(j) as MotionSprite;
						var dx:Number = ms1.x - ms0.x;
						var dy:Number = ms1.y - ms0.y;
						var dist:Number = Math.sqrt(dx * dx + dy * dy);
						var minDist:Number = (ms0.width >> 1) + (ms1.width >> 1);
						if (dist < minDist)
						{
							var angle:Number = Math.atan2(dy, dx);
							var tx:Number = ms0.x + Math.cos(angle) * minDist;
							var ty:Number = ms0.y + Math.sin(angle) * minDist;
							var ax:Number = (tx - ms1.x) * spring;
							var ay:Number = (ty - ms1.y) * spring;
							ms0.vx -= ax;
							ms0.vy -= ay;
							ms1.vx += ax;
							ms1.vy += ay;
						}
					}
				}
			}
		}
		
		public static function springToCenter(springer:Object, springee:Object, 
										gravity:Number = 0, spring:Number = 0.05, 
										friction:Number = 0.95, springLength:Number=0):void
		{
			if (!springLength)
				if (springer.width > springee.width)
					springLength = springer.width;
				else
					springLength = springee.width;
	
			var springeeCenterX:int = springee.x + (springee.width >> 1);
			var springeeCenterY:int = springee.y + (springee.height >> 1);
			var springerCenterX:int = springer.x + (springer.width >> 1);
			var springerCenterY:int = springer.y + (springer.height >> 1);
			
			var dx:Number = springeeCenterX - springerCenterX;
			var dy:Number = springeeCenterY - springerCenterY;

			var angle:Number = Math.atan2(dy, dx);
			var targetX:Number = springeeCenterX - Math.cos(angle) * springLength;
			var targetY:Number = springeeCenterY - Math.sin(angle) * springLength;
			
			springer.vx += (targetX - springerCenterX) * spring;
			springer.vy += (targetY - springerCenterY) * spring;
			springer.vx *= friction;
			springer.vy *= friction;
			springer.vy += gravity;

			springer.x += springer.vx;
			springer.y += springer.vy;
		}
		
		public static function springTo(springer:Object, springee:Object, 
										gravity:Number = 0, spring:Number = 0.05, 
										friction:Number = 0.95, springLength:Number= 200):void
		{		
			var dx:Number = springee.x - springer.x;
			var dy:Number = springee.y - springer.y;
			var angle:Number = Math.atan2(dy, dx);
			var targetX:Number = springee.x - Math.cos(angle) * springLength;
			var targetY:Number = springee.y - Math.sin(angle) * springLength;
			
			springer.vx += (targetX - springer.x) * spring;
			springer.vy += (targetY - springer.y) * spring;
			springer.vx *= friction;
			springer.vy *= friction;
			springer.vy += gravity;

			springer.x += springer.vx;
			springer.y += springer.vy;
		}
		
		public static function rotate(displayObject:DisplayObject, degreesToRotate:Number):void
		{
			var point:Point=new Point((displayObject.x + displayObject.width) >> 1, (displayObject.y + displayObject.height) >> 1);
			var m:Matrix = displayObject.transform.matrix;
			m.tx -= point.x;
			m.ty -= point.y;
			m.rotate (degreesToRotate*(Math.PI/180));
			m.tx += point.x;
			m.ty += point.y;
			displayObject.transform.matrix = m;		
		}
	}
}