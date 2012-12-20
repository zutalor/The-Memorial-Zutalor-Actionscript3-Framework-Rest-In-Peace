package com.zutalor.filters 
{
	import com.zutalor.properties.DropShadowFilterProperties;
	import flash.filters.DropShadowFilter;
	/**
	 * ...
	 * @author Geoff
	 */
	public class shadowFilter extends DropShadowFilter
	{
		private var ds:DropShadowFilter;
		
		public function shadowFilter(preset:String) 
		{
			init(preset);
		}
		
		private function init(preset:String):void
		{
			var dropShadowProperties:DropShadowFilterProperties
			dfp = _presets.getPropsByName(fip.preset);
		}
		
		
						if (dfp)
						{
							_ds = new DropShadowFilter(dfp.distance,dfp.angle,dfp.color,dfp.alpha,dfp.blurX,dfp.blurY,1,dfp.quality);					
							filters[i] = _ds;
							_d.filters = filters;
						}
		
	}

}