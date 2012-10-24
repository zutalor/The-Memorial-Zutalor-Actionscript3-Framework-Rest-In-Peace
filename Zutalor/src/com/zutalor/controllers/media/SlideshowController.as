package com.zutalor.controllers.media 
{
	import com.greensock.TweenMax;
	import com.zutalor.controllers.AbstractController;
	import com.zutalor.interfaces.IUiController;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.StageRef;
	import com.zutalor.utils.TimerRegistery;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;

	/**
	 * ...
	 * @author Geoff
	 */
	public class SlideshowController extends AbstractController implements IUiController
	{		
		public const DIM_TIME:int = 5000;
		public const FADE_SECONDS:int = 1;
		
		public function SlideshowController() 
		{
			
		}
		
		public function initialize():void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			StageRef.stage.addEventListener(MouseEvent.CLICK, onMouseMove, false, 0, true);
			MasterClock.registerCallback(dimUI, false, DIM_TIME);
		}
		
		override public function getValueObject(params:Object=null):*
		{
			return null;
		}
		
		public function setNextButtonVisibility(v:Boolean):void
		{
			if (controller.getItemByName("nextButton"))
				controller.getItemByName("nextButton").visible = v;						
		}
		
		public function setPrevButtonVisibility(v:Boolean):void
		{
			if (controller.getItemByName("prevButton"))
				controller.getItemByName("prevButton").visible = v;			
		}
		
		override public function dispose():void
		{
			MasterClock.unRegisterCallback(dimUI);
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			StageRef.stage.removeEventListener(MouseEvent.CLICK, onMouseMove);
		}
			
		// PRIVATE METHODS
		
		private function onMouseMove(e:Event):void
		{			
			Mouse.show();			
			if (!controller.container.visible)
			{
				controller.container.visible = true;
				TweenMax.to(controller.container, FADE_SECONDS, {alpha:1} );
				MasterClock.resetAndStart(dimUI);
			}
		}
		
		private function dimUI():void
		{
			MasterClock.unRegisterCallback(dimUI);
			Mouse.hide();	
			TweenMax.to(controller.container, FADE_SECONDS, {alpha:0, visible:false} );
		}
	}
}