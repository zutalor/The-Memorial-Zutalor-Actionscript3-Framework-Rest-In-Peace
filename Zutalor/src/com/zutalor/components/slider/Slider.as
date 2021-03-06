package com.zutalor.components.slider
{
	import com.zutalor.components.button.Button;
	import com.zutalor.components.base.Component;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.interfaces.IComponent;
	import com.zutalor.events.UIEvent;
	import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.translate.Translate;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	 //NOTE: TODO There is a bug in the track click area. Doesn't update the value properly
	 
	public class Slider extends Component implements IComponent
	{
		private var _sliderController:ScrollBarController;
		private var _thumb:Button;
		private var _track:Button;
		private var _reveal:Graphic;
		
		protected static var _presets:PropertyManager;		
		
		public function Slider(name:String)
		{
			super(name);
		}

		public static function registerPresets(options:Object):void
		{	
			if (!_presets)
				_presets = new PropertyManager(SliderProperties);
			
			_presets.parseXML(options.xml[options.nodeId]);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var sp:SliderProperties;
	
			super.render(viewItemProperties);
			sp = _presets.getPropsByName(vip.presetId);
			
			_track = new Button(vip.name);
			_track.vip.presetId = sp.trackButtonId;
			_track.render();
			
			_thumb = new Button(vip.name);
			_thumb.vip.presetId = sp.thumbButtonId;
			_thumb.vip.text = Translate.text(vip.tKey);
			_thumb.vip.textAttributes = vip.textAttributes;
			_thumb.render();

			if (sp.revealId)
			{
				_reveal = new Graphic(vip.name);
				_reveal.vip.presetId = sp.revealId;
				_reveal.render();
			}
			
			if (sp.vertical)
				_sliderController = new VScrollBarController(this, _thumb, _track, _reveal, sp.tweenTime, sp.numSteps, sp.onlyShowTrackOnMouseDown);
			else
				_sliderController = new HScrollBarController(this, _thumb, _track, _reveal, sp.tweenTime, sp.numSteps, sp.onlyShowTrackOnMouseDown);
				
			_sliderController.addEventListener(UIEvent.VALUE_CHANGED, onValueChange, false, 0, true);		
		}
		
		public function get track():Sprite
		{
			return _track;
		}
		
		public function get thumb():Sprite
		{
			return _thumb;
		}
		
		override public function set value(p:*):void
		{
			_sliderController.setPercent(p);
			super.value = p;
		}
		
		override public function get value():*
		{
			return _sliderController.getPercent();
		}
	}
}