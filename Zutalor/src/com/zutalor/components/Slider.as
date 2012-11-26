package com.zutalor.components
{
	import com.zutalor.events.UIEvent;
	import com.zutalor.properties.SliderProperties;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.scroll.HScrollBarController;
	import com.zutalor.scroll.ScrollBarController;
	import com.zutalor.scroll.VScrollBarController;
	import com.zutalor.text.Translate;
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
		
		public static function register(presets:XMLList):void
		{	
			if (!_presets)
				_presets = new PropertyManager(SliderProperties);
			
			_presets.parseXML(presets);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var sp:SliderProperties;
	
			super.render(viewItemProperties);
			sp = presets.getPropsByName(vip.presetId);
			
			_track = new Button();
			_track.vip.presetId = sp.trackButtonId;
			_thumb = new Button();
			_thumb.vip.presetId = sp.thumbButtonId;
			_thumb.vip.text = Translate.text(vip.tKey);
			_thumb.vip.textAttributes = vip.textAttributes;

			if (sp.revealId)
			{
				_reveal = new Graphic();
				_reveal.vip.presetId = sp.revealId;
				_reveal.render();
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