package com.zutalor.controllers.media 
{
	import com.greensock.TweenMax;
	import com.zutalor.controllers.base.UXControllerBase;
	import com.zutalor.interfaces.IUXController;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.StageRef;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	/**
	 * ...
	 * @author Geoff
	 */
	public class MediaTransportController extends UXControllerBase implements IUXController
	{
		private var _mediaTransportVO:MediaTransportVO;
		private var _dimTime:uint;
		private var _fadeTime:int;
		
		public const DIM_TIME:int = 1800;
		public const FADE_SECONDS:int = 1;
		
		public function MediaTransportController() 
		{
			_init();
		}
		
		private function _init():void
		{
			_mediaTransportVO = new MediaTransportVO;
			
		}
		
		override public function getValueObject(params:Object=null):*
		{
			return _mediaTransportVO;
		}
		
		
		override public function dispose():void
		{
			MasterClock.unRegisterCallback(dimUI);
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		override public function valueUpdated(itemName:String):void
		{
			switch (itemName)
			{
				case "bufferFull" :
					break;
				case "playing" :	
					if (_mediaTransportVO.playing)
						play();
					else
						stop();
					break;
			}
		}
		
		// PRIVATE METHODS
		
		private function play():void
		{	
			if (_mediaTransportVO.dimTime)
				_dimTime = _mediaTransportVO.dimTime * 1000;
			else
				_dimTime = DIM_TIME;
			
			if (_mediaTransportVO.fadeTime)
				_fadeTime = _mediaTransportVO.fadeTime;
			else
				_fadeTime = FADE_SECONDS;
					
			MasterClock.registerCallback(dimUI, true, _dimTime);
			
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			if (controller.getItemByName("bigPlayButton"))
				controller.getItemByName("bigPlayButton").visible = false;
		}
		
		private function stop():void
		{
			MasterClock.stop(dimUI);
			controller.container.visible = true;
		}
		
		private function onMouseMove(e:Event):void
		{			
			Mouse.show();	
			MasterClock.resetAndStart(dimUI);			
			if (!controller.container.visible)
			{
				TweenMax.to(controller.container, _fadeTime, {alpha:1} );
				controller.container.visible = true;
			}
		}
		
		private function dimUI():void
		{
			if (controller.container.visible)
			{
				Mouse.hide();	
				TweenMax.to(controller.container, _mediaTransportVO.fadeTime, { alpha:0, visible:false } );
			}
		}
	}
}