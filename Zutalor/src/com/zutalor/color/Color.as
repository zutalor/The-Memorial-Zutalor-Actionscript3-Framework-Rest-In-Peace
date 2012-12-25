package com.zutalor.color 
{
	import com.zutalor.properties.NestedPropsManager;
	import com.zutalor.utils.ShowError;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Color 
	{			
		private static var _presets:NestedPropsManager;
		private static var _theme:String;
		
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new NestedPropsManager();
			
			_presets.parseXML(ColorProperties, ColorItemProperties, options.xml[options.nodeId],
																options.childNodeId, options.xml[options.childNodeId]);
		}
		
		public static function set theme(t:String):void
		{
			if (_presets.getPropsById(t))
				_theme = t;
		}
		
		public static function get theme():String
		{
			return _theme;
		}
		
		
		public static function getColor(themeId:String, id:String):uint
		{
			var ctp:ColorProperties;
			var ctip:ColorItemProperties;
			var color:Number;
			var hueShift:Number;
			var saturationShift:Number;
			var luminanceShift:Number;
			
			ctp = _presets.getPropsById(themeId);
			
			if (!ctp)
				ShowError.fail(Color, "No color theme found: " + themeId);
				
			hueShift = ctp.hueShift;
			saturationShift = ctp.saturationShift;
			luminanceShift = ctp.luminanceShift;				
			
			if (ctp.basedOnTheme)
				ctp = _presets.getPropsById(ctp.basedOnTheme);
			
			if (!hueShift)
				hueShift = ctp.hueShift;
				
			if (!saturationShift)
				saturationShift = ctp.saturationShift;
				
			if (!luminanceShift)
				luminanceShift = ctp.luminanceShift;
				
			if (ctp.basedOnItem)
				ctip = _presets.getItemPropsByName(ctp.name, ctp.basedOnItem);
			else
				ctip = _presets.getItemPropsByName(themeId, id);
	
			if (!hueShift)
				hueShift = 0;
				
			if (!saturationShift)
				saturationShift = 0;
				
			if (!luminanceShift)
				luminanceShift = 0;
				
			if (ctip)
				color = HSL.getHex(ctip.hue + hueShift, ctip.saturation + saturationShift, ctip.luminance + luminanceShift);
			else
				ShowError.fail(Color, "No color item for theme: " + themeId + " for " + id);
				
			return color;	
		}
	}
}