package com.zutalor.propertyManagers
{
	import com.zutalor.components.button.Button;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.components.group.ComponentGroup;
	import com.zutalor.components.html.StyleSheets;
	import com.zutalor.components.list.List;
	import com.zutalor.components.media.base.MediaPlayer;
	import com.zutalor.components.stepper.Stepper;
	import com.zutalor.components.text.Text;
	import com.zutalor.components.toggle.Toggle;
	import com.zutalor.fx.Transition;
	import com.zutalor.properties.AppStateProperties;
	import com.zutalor.properties.ColorProperties;
	import com.zutalor.properties.DropShadowFilterProperties;
	import com.zutalor.properties.GlowFilterProperties;
	import com.zutalor.properties.RippleProperties;
	import com.zutalor.properties.ScrollProperties;
	import com.zutalor.properties.ToolTipProperties;
	import com.zutalor.properties.UIProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.utils.Singleton;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Presets
	{
		public static var scrollPresets:PropertyManager;
		public static var uiPresets:PropertyManager;
		public static var toolTipPresets:PropertyManager;
		public static var shadowPresets:PropertyManager;
		public static var glowPresets:PropertyManager;
		public static var ripplePresets:PropertyManager;
		public static var hotkeyPresets:PropertyManager;
		public static var appStates:PropertyManager;
		public static var colorPresets:PropertyManager;
		
		private static var _registrey:Vector.<PresetRegistryProperties>;
		
		public static function register(presetClass:*, nodeId:String, childNodeId:String = null, alternateFunction:Function = null):void
		{
			if (!_registrey)
			{
				_registrey = new Vector.<PresetRegistryProperties>;
				init();
			}
			var p:PresetRegistryProperties = new PresetRegistryProperties();
			
			p.presetClass = presetClass;
			p.nodeId = nodeId;
			p.childNodeId = childNodeId;
			p.alternateFunction = alternateFunction;
			
			_registrey.push(p);
		}
		
		public static function parseXML(xml:XML):void
		{
			var l:int;
			l = _registrey.length;
			
			for (var i:int = 0; i < l; i++)
			{
				var f:Function;
				var p:PresetRegistryProperties;
				
				p = _registrey[i];
				
				if (p.alternateFunction != null)
					f = p.alternateFunction;
				else
					f = p.presetClass.register;
			
				f(xml[ p.nodeId ], xml);

			}

			scrollPresets.parseXML(xml.scrollPresets);
			uiPresets.parseXML(xml.uiPresets);
			toolTipPresets.parseXML(xml.toolTipPresets);
			shadowPresets.parseXML(xml.shadowPresets);
			glowPresets.parseXML(xml.glowPresets);
			ripplePresets.parseXML(xml.ripplePresets);

			colorPresets.parseXML(xml.colorPresets);			
			appStates.parseXML(xml.appStates);
		}
			
		private static function init():void
		{
			scrollPresets = new PropertyManager(ScrollProperties);
			uiPresets = new PropertyManager(UIProperties);
			toolTipPresets = new PropertyManager(ToolTipProperties);
			shadowPresets = new PropertyManager(DropShadowFilterProperties);
			glowPresets = new PropertyManager(GlowFilterProperties);
			ripplePresets = new PropertyManager(RippleProperties);
			appStates = new PropertyManager(AppStateProperties);
			colorPresets = new PropertyManager(ColorProperties);
		}
	}
}