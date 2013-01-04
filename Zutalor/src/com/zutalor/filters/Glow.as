package com.zutalor.filters 
{
	import com.zutalor.filters.base.FuzzyFilter;
	import com.zutalor.filters.base.FuzzyFilterProperties;
	import com.zutalor.properties.PropertyManager;
	import flash.filters.GlowFilter;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Glow extends FuzzyFilter 
	{		
		override protected function reflect():Class
		{
			return GlowFilter;
		}
	}
}