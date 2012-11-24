﻿package com.zutalor.propertyManagers
{
	import com.zutalor.components.Button;
	import com.zutalor.components.ComponentGroup;
	import com.zutalor.components.Graphic;
	import com.zutalor.components.Stepper;
	import com.zutalor.components.Toggle;
	import com.zutalor.fx.Transition;
	import com.zutalor.properties.AppStateProperties;
	import com.zutalor.properties.ColorProperties;
	import com.zutalor.properties.DropShadowFilterProperties;
	import com.zutalor.properties.GlowFilterProperties;
	import com.zutalor.properties.MediaProperties;
	import com.zutalor.properties.RippleProperties;
	import com.zutalor.properties.ScrollProperties;
	import com.zutalor.properties.ToolTipProperties;
	import com.zutalor.properties.UIProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.text.StyleSheets;
	import com.zutalor.text.TextAttributes;
	import com.zutalor.utils.Singleton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Presets
	{
		public var scrollPresets:PropertyManager;
		public var mediaPresets:PropertyManager;
		public var uiPresets:PropertyManager;
		public var toolTipPresets:PropertyManager;
		public var shadowPresets:PropertyManager;
		public var textAttributePresets:PropertyManager;
		public var glowPresets:PropertyManager;
		public var ripplePresets:PropertyManager;
		public var hotkeyPresets:PropertyManager;
		public var appStates:PropertyManager;
		public var colorPresets:PropertyManager;
		
		private static var _presets:Presets;
		
		public function Presets() 
		{
			init();  
		}
		
		private function init():void
		{
			Singleton.assertSingle(Presets);
			scrollPresets = new PropertyManager(ScrollProperties);
			mediaPresets = new PropertyManager(MediaProperties);
			uiPresets = new PropertyManager(UIProperties);
			toolTipPresets = new PropertyManager(ToolTipProperties);
			shadowPresets = new PropertyManager(DropShadowFilterProperties);
		
			glowPresets = new PropertyManager(GlowFilterProperties);
			ripplePresets = new PropertyManager(RippleProperties);
	
			appStates = new PropertyManager(AppStateProperties);
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
			Graphic.register(xml.graphicStylePresets);
			Transition.register(xml.transitionPresets);
			Button.register(xml.transitionPresets);
			Toggle.register(xml.togglePresets);
			Stepper.register(xml.stepperPresets);
			ComponentGroup.register(xml.componentGroupPresets);
			TextAttributes.register(xml.textAttributePresets, xml.textFormatPresets);
			StyleSheets.register(xml.cssPresets);
			
			scrollPresets.parseXML(xml.scrollPresets);
			mediaPresets.parseXML(xml.mediaPresets);
			uiPresets.parseXML(xml.uiPresets);
			toolTipPresets.parseXML(xml.toolTipPresets);
			shadowPresets.parseXML(xml.shadowPresets);
			glowPresets.parseXML(xml.glowPresets);
			ripplePresets.parseXML(xml.ripplePresets);

			colorPresets.parseXML(xml.colorPresets);			
			appStates.parseXML(xml.appStates);
		}
	}
}