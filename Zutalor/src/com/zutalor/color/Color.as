package com.zutalor.color 
{
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.utils.ShowError;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Color 
	{			
		public static var _presets:NestedPropsManager;
		
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new NestedPropsManager();
			
			_presets.parseXML(ColorThemeProperties, ColorThemeItemProperties, options.xml[options.nodeId],
																options.childNodeId, options.xml[options.childNodeId]);
		}
		
		public static function getColor(themeId:String, id:String):Number
		{
			var ctp:ColorThemeProperties;
			var ctip:ColorThemeItemProperties;
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
			
			if (ctp.derivedFromTheme)
				ctp = _presets.getPropsById(ctp.derivedFromTheme);
			
			if (!hueShift)
				hueShift = ctp.hueShift;
				
			if (!saturationShift)
				saturationShift = ctp.saturationShift;
				
			if (!luminanceShift)
				luminanceShift = ctp.luminanceShift;
				
			if (ctp.derivedFromItem)
				ctip = _presets.getItemPropsByName(ctp.name, ctp.derivedFromItem);
			else
				ctip = _presets.getItemPropsByName(themeId, id);
	
			if (ctip)
				color = HSL.getHex(ctip.hue + hueShift, ctip.saturation + saturationShift, ctip.luminance + luminanceShift);
			else
				ShowError.fail(Color, "No color item for theme: " + themeId + " for " + id);
				
			return color;	
		}
	}
}