package com.zutalor.components
{
	import com.zutalor.containers.AbstractContainer;
	import com.zutalor.events.UIEvent;
	import com.zutalor.scroll.HScrollBarController;
	import com.zutalor.scroll.ScrollBarController;
	import com.zutalor.scroll.VScrollBarController;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Slider extends AbstractContainer
	{
		private var _sliderController:ScrollBarController;
		private var _thumb:Button;
		private var _track:Button;
		private var _reveal:DisplayObject;
		private var _revealMask:Sprite;
		
		public function Slider()
		{
		}
		
		
		public function create(thumb:Button, track:Button, reveal:DisplayObjectContainer = null, 
								vertical:Boolean = false, tweenTime:Number=0, numSteps:int=0, onlyShowTrackOnMouseDown:Boolean=false):void
		{
			_thumb = thumb;
			_track = track;
			if (vertical)
			{
				_sliderController = new VScrollBarController(this, thumb, track, reveal, tweenTime, numSteps, onlyShowTrackOnMouseDown);
			}
			else
			{
				_sliderController = new HScrollBarController(this, thumb, track, reveal, tweenTime, numSteps, onlyShowTrackOnMouseDown);
			}	
			_sliderController.addEventListener(UIEvent.VALUE_CHANGED, dispatchValueChange, false, 0, true);		
		}
		
		public function get thumb():Button
		{
			return _thumb;
		}
		
		public function get track():Button
		{
			return _track;
		}
		
		
		public function dispatchValueChange(uie:UIEvent):void
		{
			dispatchEvent(uie.clone());
		}
		
		public function get value():Number
		{
			return _sliderController.getPercent();
		}
		
		public function set value(p:Number):void
		{
			_sliderController.setPercent(p);
		}
	}
}