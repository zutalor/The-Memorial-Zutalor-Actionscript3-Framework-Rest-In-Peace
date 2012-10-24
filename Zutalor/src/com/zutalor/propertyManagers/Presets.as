package com.zutalor.propertyManagers
{
	import com.zutalor.properties.ButtonProperties;
	import com.zutalor.properties.ColorProperties;
	import com.zutalor.properties.CssProperties;
	import com.zutalor.properties.DropShadowFilterProperties;
	import com.zutalor.properties.GlowFilterProperties;
	import com.zutalor.properties.GraphicStyleProperties;
	import com.zutalor.properties.MediaProperties;
	import com.zutalor.properties.ComponentGroupProperties;
	import com.zutalor.properties.MenuProperties;
	import com.zutalor.properties.RippleProperties;
	import com.zutalor.properties.ScrollProperties;
	import com.zutalor.properties.SliderProperties;
	import com.zutalor.properties.SoundFxProperties;
	import com.zutalor.properties.StepperProperties;
	import com.zutalor.properties.TextAttributeProperties;
	import com.zutalor.properties.TextFormatProperties;
	import com.zutalor.properties.TextListProperties;
	import com.zutalor.properties.ToggleProperties;
	import com.zutalor.properties.ToolTipProperties;
	import com.zutalor.properties.TransitionProperties;
	import com.zutalor.properties.TranslateProperties;
	import com.zutalor.properties.UIProperties;
	import com.zutalor.properties.ViewProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.Singleton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Presets
	{
		public var scrollPresets:PropertyManager;
		public var transitionPresets:PropertyManager;
		public var mediaPresets:PropertyManager;
		public var uiPresets:PropertyManager;
		public var cssPresets:PropertyManager;
		public var toolTipPresets:PropertyManager;
		public var shadowPresets:PropertyManager;
		public var textAttributePresets:PropertyManager;
		public var mouseFxPresets:PropertyManager;
		public var soundFxPresets:PropertyManager;
		public var glowPresets:PropertyManager;
		public var ripplePresets:PropertyManager;
		public var hotkeyPresets:PropertyManager;
		public var graphicStylePresets:PropertyManager;
		public var buttonPresets:PropertyManager;
		public var componentGroupPresets:PropertyManager;
		public var togglePresets:PropertyManager;
		public var sliderPresets:PropertyManager;
		public var stepperPresets:PropertyManager;
		public var textListPresets:PropertyManager;
		public var textFormatPresets:PropertyManager;
		public var menu:PropertyManager;
		public var colorPresets:PropertyManager;
		
		private static var _presets:Presets;
		
		public function Presets() 
		{
			init();  //TODO make this "injectable" so that the main class can create an arbitrary # of presets.
		}
		
		private function init():void
		{
			Singleton.assertSingle(Presets);
			scrollPresets = new PropertyManager(ScrollProperties);
			transitionPresets = new PropertyManager(TransitionProperties);
			mediaPresets = new PropertyManager(MediaProperties);
			uiPresets = new PropertyManager(UIProperties);
			toolTipPresets = new PropertyManager(ToolTipProperties);
			shadowPresets = new PropertyManager(DropShadowFilterProperties);
			textAttributePresets = new PropertyManager(TextAttributeProperties);
			soundFxPresets = new PropertyManager(SoundFxProperties);
			glowPresets = new PropertyManager(GlowFilterProperties);
			ripplePresets = new PropertyManager(RippleProperties);
			graphicStylePresets = new PropertyManager(GraphicStyleProperties);
			buttonPresets = new PropertyManager(ButtonProperties);
			componentGroupPresets = new PropertyManager(ComponentGroupProperties);
			sliderPresets = new PropertyManager(SliderProperties);
			togglePresets = new PropertyManager(ToggleProperties);
			stepperPresets = new PropertyManager(StepperProperties);
			textListPresets = new PropertyManager(TextListProperties);
			textFormatPresets = new PropertyManager(TextFormatProperties);
			cssPresets = new PropertyManager(CssProperties);
			menu = new PropertyManager(MenuProperties);
			colorPresets = new PropertyManager(ColorProperties);
		}
				
		public static function gi():Presets
		{
			if (!_presets)
				_presets = new Presets();
			
			return _presets;
		}
		
		public function parseXML(xml:XML):void
		{
			scrollPresets.parseXML(xml.scrollPresets);
			transitionPresets.parseXML(xml.transitionPresets);
			mediaPresets.parseXML(xml.mediaPresets);
			uiPresets.parseXML(xml.uiPresets);
			toolTipPresets.parseXML(xml.toolTipPresets);
			shadowPresets.parseXML(xml.shadowPresets);
			textAttributePresets.parseXML(xml.textAttributePresets);
			soundFxPresets.parseXML(xml.soundFxPresets);
			glowPresets.parseXML(xml.glowPresets);
			ripplePresets.parseXML(xml.ripplePresets);
			graphicStylePresets.parseXML(xml.graphicStylePresets);
			buttonPresets.parseXML(xml.buttonPresets);
			componentGroupPresets.parseXML(xml.componentGroupPresets);
			sliderPresets.parseXML(xml.sliderPresets);
			togglePresets.parseXML(xml.togglePresets);
			stepperPresets.parseXML(xml.stepperPresets);
			textListPresets.parseXML(xml.textListPresets);
			textFormatPresets.parseXML(xml.textFormatPresets);
			cssPresets.parseXML(xml.cssPresets);
			colorPresets.parseXML(xml.colorPresets);			
			menu.parseXML(xml.menu);
		}
	}
}