package com.zutalor.motion
{
	import com.zutalor.containers.ViewObject;
	import com.zutalor.containers.ViewObject;
	import com.zutalor.containers.ScrollingContainer;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.Motion;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import com.zutalor.utils.TimerRegistery;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import com.zutalor.utils.Singleton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MotionUtils extends EventDispatcher
	{		
		public var chainChildren:Boolean = false;
		public var collisionDetect:Boolean = false;
		public var allowDragging:Boolean = true;
	
		public var bounce:Number = -1;
		public var squish:Number = 0;
		public var friction:Number = .9;
		public var windVx:Number = 0;
		public var windVy:Number = 0;
		public var gravity:Number = 0;
		
		private var _velocityTolerance:Number = 0.05;
		private var _maxVelocity:Number = 40;

		private var _oldX:Number;
		private var _oldY:Number;
		private var _oldAlpha:Number;
		
		private var _mouseDownX:Number;
		private var _mouseUpX:Number;
		private var _mouseDownY:Number;
		private var _mouseUpY:Number;
		
		private var _draggingNow:ViewObject;
		private	var _sc:ScrollingContainer;
		
		private var ap:ApplicationProperties;
		private var vpm:NestedPropsManager;
		
		private var _checkMotion:Boolean;
		
		private static var _motionUtils:MotionUtils;
		
		public function MotionUtils() 
		{
			_init();
		}
		
		private function _init():void
		{
			Singleton.assertSingle(Motion);
			ap = ApplicationProperties.gi();
			vpm = Props.views;
		}
		
		public static function gi():MotionUtils
		{
			if (!_motionUtils)
				_motionUtils = new MotionUtils();
			
			return _motionUtils;
		}						
			
		public function enableMotionChecking():void
		{
			_checkMotion = true;
			MasterClock.registerCallback(onMotionTimer, true);
		}
		
		public function disableMotionChecking():void
		{
			MasterClock.unRegisterCallback(onMotionTimer);
			_checkMotion = false;
		}
						
		private function onMotionTimer(DraggingNow:DisplayObject=null):void
		{	
			var ms:ViewObject;
			var stageInMotion:Boolean;
			var left:Number;
			var right:Number;
			var top:Number;
			var bottom:Number;								
			var bounce:Number = -.5;
			var overlap:Number = 75;
						
			stageInMotion = false;

			if (_checkMotion)
				for (var i:int = 0; i < StageRef.stage.numChildren; ++i)
				{
					if (StageRef.stage.getChildAt(i) is ViewObject)
					{
						ms = StageRef.stage.getChildAt(i) as ViewObject;
						
						if (!ms.vx && !ms.vy)
						{
							ms.inMotion = false;
						}
						else
						{
							stageInMotion = true;
							ms.cacheAsBitmap = true;						
					//	trace("motion sprite cache as bitmap");
							if (ms.dragType == "drag")
							{
								if (ms != _draggingNow)
								{		
									if (ms.vx > _maxVelocity)
										ms.vx = _maxVelocity;
										
									if (ms.vy > _maxVelocity)
										ms.vy = _maxVelocity;
										
									if (Math.abs(ms.vx) < _velocityTolerance && Math.abs(ms.vy) < _velocityTolerance)
									{
										ms.inMotion = false;
										ms.vx = 0;
										ms.vy = 0;
									} 
									else 
										ms.inMotion = true;							
									
									bottom = ms.stage.stageHeight + ms.height - overlap;
									right = ms.stage.stageWidth + ms.width - overlap;
									top = (ms.height - overlap) * -1;
									left = (ms.width - overlap) * -1;
									
									if ( ms.x + ms.width > right)
									{
										ms.x = right - ms.width;
										ms.vx *= bounce;
									}
									else if(ms.x < left)
									{
										ms.x = left;
										ms.vx *= bounce;
									}
									
									if (ms.y + ms.height > bottom)
									{
										ms.y = bottom - ms.height;
										ms.vy *= bounce;
									}
									else if(ms.y < top)
									{
										ms.y = top;
										ms.vy *= bounce;
									}
									
									ms.vx *= friction;
									ms.vy *= friction;
									
									ms.vy += gravity;
									ms.vy += windVy * ms.windAffect;
									ms.vx += windVx * ms.windAffect;
									
									ms.vy //*= 1 / Scale.curAppScaleY;
									ms.vx //*= 1 / Scale.curAppScaleX;
									
									ms.x += ms.vx;
									ms.y += ms.vy;
									//if (ms.rotvx)
									//	ms.rotationX += ms.rotvx;
									//if (ms.rotvy)
									//	ms.rotationY += ms.rotvy;
									
									ms.posOffsetX += ms.vx;
									ms.posOffsetY += ms.vy;										
								}
							}
						}
					}
			}
			if (!stageInMotion)
			{
				MasterClock.stop(onMotionTimer);
				_checkMotion = false;
			}
		}
		
		public function containerMotion():void
		{
			/*
			if (chainChildren) 
			{
				Motion.chainContainerChildren(contentContainer);
			}
			if (collisionDetect)
			{
				Motion.checkForCollision(contentContainer);
			}
			*/
		}
		
		public function gainedFocus():void
		{
			/*
			for (var i:int = 0; i < numContainerChildren; i++)
				{
					if (ms == getChildFromContainerByIndex(i))
					{
						TweenMax.to(ms, .5, { scaleX:1, scaleY:1 } );
					}
					else
						lostFocus(getChildFromContainerByIndex(i) as ViewObject);
				}
				*/
		}
		
		public function lostFocus(ms:ViewObject):void
		{
			//weenMax.to(ms, .5, { scaleX:.5, scaleY:.5 } );
		}

		
		public function onMouseDown(event:MouseEvent):void
		{
			var ms:ViewObject;
			
			ms = vpm.getPropsById(event.target.name).container;
			
			if (!ms)
				ms = event.target as ViewObject;

			if (ms)
			{	
				_mouseDownX = StageRef.stage.mouseX;
				_mouseDownY = StageRef.stage.mouseY;
				
				_draggingNow = ms;
				_sc = _draggingNow as ScrollingContainer;

				ms.dragging = true;
				ms.inMotion = true;
				_oldX = ms.savedX = ms.x;
				_oldY = ms.savedY = ms.y;
				_oldAlpha = ms.alpha;
				_draggingNow.addEventListener(Event.ENTER_FRAME, trackMouseVelocity, false, 0, true);
				StageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
				
				if (ms.dragType == "drag")
				{
					ms.alpha *= .5;
					ms.startDrag();
				}
			}
		}
				
		private function onMouseUp(event:MouseEvent):void
		{
			var xVelocity:Number;
			var yVelocity:Number;
			
			if (_draggingNow)
			{
				_draggingNow.dragging = false;
				_draggingNow.removeEventListener(Event.ENTER_FRAME, trackMouseVelocity);					
				
				if (_draggingNow.dragType == "drag")
				{
					_draggingNow.posOffsetX += (_draggingNow.x - _draggingNow.savedX) ;
					_draggingNow.posOffsetY += (_draggingNow.y - _draggingNow.savedY) ;			
					_draggingNow.stopDrag();
					_draggingNow.alpha = _oldAlpha;
					Motion.checkBounds(_draggingNow.stage.stageWidth, _draggingNow.stage.stageHeight, _draggingNow);					
				}
				else
				{	
					xVelocity = _sc.vx / _sc.width * 10 * -1 ;
					yVelocity = _sc.vy / _sc.height * 10 * -1 ;
			
					_sc.tweenScrollPercentX(_sc.scrollPercentX + xVelocity * (1 / Scale.curAppScale));
					_sc.tweenScrollPercentY(_sc.scrollPercentY + yVelocity * (1 / Scale.curAppScale));

					_sc.vx = 0;
					_sc.vy = 0;

					_sc.inMotion = false;
				}
				_draggingNow = null;
			}
		}
		
		private function trackMouseVelocity(event:Event):void
		{
			var ms:ViewContainer;
			var xDistance:Number;
			var yDistance:Number;		

			_checkMotion = true;
			MasterClock.start(onMotionTimer);
			
			ms = event.target as ViewContainer;
			if (ms.dragType != "drag")
			{	
				xDistance = ((StageRef.stage.mouseX - _mouseDownX) / StageRef.stage.stageWidth) *  Scale.curAppScale * .17 * (1 / ms.scaleX);
				yDistance = ((StageRef.stage.mouseY - _mouseDownY) / StageRef.stage.stageHeight) * Scale.curAppScale * .17 * (1 / ms.scaleY);
				
				_sc.tweenScrollPercentX(_sc.scrollPercentX + xDistance * -1, 0);
				_sc.tweenScrollPercentY(_sc.scrollPercentY + yDistance * -1, 0);
				
				ms.vx = (ms.mouseX - _oldX);
				ms.vy = (ms.mouseY - _oldY);
				
				_oldX = ms.mouseX;
				_oldY = ms.mouseY;

			}	
			else
			{
				ms.vx = StageRef.stage.mouseX - _oldX;
				ms.vy = StageRef.stage.mouseY - _oldY;
				_oldX = StageRef.stage.mouseX;
				_oldY = StageRef.stage.mouseY;
			}
		}
	}
}