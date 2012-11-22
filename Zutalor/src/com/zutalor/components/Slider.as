package com.zutalor.components
{
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.PropertiesBase;
	import com.zutalor.properties.SliderProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.scroll.HScrollBarController;
	import com.zutalor.scroll.ScrollBarController;
	import com.zutalor.scroll.VScrollBarController;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Slider extends Component implements IComponent
	{
		private var _sliderController:ScrollBarController;
		private var _thumb:Button;
		private var _track:Button;
		private var _reveal:Graphic;
	
		public function Slider(id:String, text:String = null)
		{
			init(id, text);
		}
		
		public static function register(preset:XMLList):void
		{	
			if (!presets)
				presets = new PropertyManager(SliderProperties);
			
			presets.parseXML(preset);
		}
		
		private function init(sliderId:String, text:String):void
		{
			var sp:SliderProperties;
			
			_track = new Button(sp.trackButtonId);
			_thumb = new Button(sp.thumbButtonId, text);
	
			sp = presets.getPropsByName(sliderId);

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
		
		override public function get value():*
		{
			return _sliderController.getPercent();
		}
		
		override public function set value(p:*):void
		{
			_sliderController.setPercent(p);
		}
	}
}