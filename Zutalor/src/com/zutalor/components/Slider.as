package com.zutalor.components
{
	import com.zutalor.containers.Container;
	import com.zutalor.events.UIEvent;
	import com.zutalor.interfaces.IViewItem;
	import com.zutalor.properties.SliderProperties;
	import com.zutalor.propertyManagers.Props;
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
	public class Slider extends Container implements IViewItem
	{
		private var _sliderController:ScrollBarController;
		private var _name:String;
		private var _thumb:Button;
		private var _track:Button;
		private var _reveal:Graphic;
		
		public function Slider(sliderId:String, text:String = null)
		{
			init(sliderId, text);
		}
		
		private function init(sliderId:String, text:String):void
		{
			var sp:SliderProperties;
			
			_track = new Button(sp.trackButtonId);
			_thumb = new Button(sp.thumbButtonId, text);
	
			sp = Props.pr.sliderPresets.getPropsByName(sliderId);

			if (sp.revealGraphicId)
			{
				_reveal = new Graphic();
				_reveal.render(sp.revealGraphicId);
			}
			
			if (sp.vertical)
				_sliderController = new VScrollBarController(this, _thumb, _track, _reveal, sp.tweenTime, sp.numSteps, sp.onlyShowTrackOnMouseDown);
			else
				_sliderController = new HScrollBarController(this, _thumb, _track, _reveal, sp.tweenTime, sp.numSteps, sp.onlyShowTrackOnMouseDown);
				
			_sliderController.addEventListener(UIEvent.VALUE_CHANGED, dispatchValueChange, false, 0, true);		
		}
		
		public function get track():Sprite
		{
			return _track;
		}
		
		public function get thumb():Sprite
		{
			return _thumb;
		}
		
		override public function set name(n:String):void
		{
			_name = _track.name = _thumb.name = _reveal.name = n;
		}
		
		override public function get name():String
		{
			return _name;
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